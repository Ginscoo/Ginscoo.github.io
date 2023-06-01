## 实现原理
JPA提供`AttributeConverter`接口用于实现数据库和实体之间数据的转换。利用这个特性可以在转换时进行加解密，从而实现自动加解密的功能


### 定义一个 `Converter`
* 定义一个`SensitiveConverter` 实现JPA的` AttributeConverter<String, String>`
* `convertToDatabaseColumn` entity值转换为数据库值，可实现加密逻辑
* `convertToEntityAttribute` 将数据库值转换为entity值，可实现解密
```Java
@Converter
public class SensitiveConverter implements AttributeConverter<String, String> {

    @Override
    public String convertToDatabaseColumn(String attribute) {
        // TODO: 2023/5/30 加密逻辑 
        return null;
    }

    @Override
    public String convertToEntityAttribute(String dbData) {
        // TODO: 2023/5/30 解密逻辑 
        return null;
    }
}

```

### 定义一个实体
定义一个User实体，通过`@Convert(converter = SensitiveConverter.class)`注解的需要加密的属性。
* 在JPA入库时会自动调用`SensitiveConverter#convertToDatabaseColumn` 方法，在这个方法内实现加密逻辑
* 在JPA查询时会自动调用`SensitiveConverter#convertToEntityAttribute`方法，可以实现解密逻辑
```Java
@Getter
@Setter
@Entity
public class User {
    @Id
    private Long id;
    
    private String username;

    @Convert(converter = SensitiveConverter.class)
    private String password;
}
```

## 优雅实现
上边的是实现方式，需要在字段上增加`@Convert(converter = SensitiveConverter.class)`,由于`@Convert`可用用于任意类型的转换，`converter`的值可以是任意实现了`AttributeConverter`的类型。
这里我们可以借助`JSR 269: Pluggable Annotation Processing API` 通过插件式注解处理方式，通过定义一个`Sensitive`注解，在编译时自动替换成`@Convert(converter = SensitiveConverter.class)` （有点类似于C的宏）

### 定义敏感数据注解 - @Sensitive
* `@Retention(RetentionPolicy.SOURCE)`：注解仅在源码阶段生效，编译后会自动转换为`@Convert(converter = SensitiveConverter.class)`
* `@Target({ElementType.FIELD, ElementType.METHOD, ElementType.TYPE})`: 可使用注解的范围，这里和`@Convert`保持一致即可
```Java
@Retention(RetentionPolicy.SOURCE)
@Target({ElementType.FIELD, ElementType.METHOD, ElementType.TYPE})
public @interface Sensitive {
}
```

### 定义注解处理器 - SensitiveProcessor
继承`AbstractProcessor` 在编译时对注解进行处理
```Java
@SupportedSourceVersion(value = SourceVersion.RELEASE_8)
@SupportedAnnotationTypes(value = "net.reduck.sdp.annotation.Sensitive")
public class SensitiveProcessor extends AbstractProcessor {
    private Types types = null;
    private Elements elements = null;
    private Filer filer = null;
    private Messager messager = null;

    private JavacTrees trees;
    private TreeMaker treeMaker;
    private Names names;
    private Symtab symtab;
    private AstMojo astMojo;

    public SensitiveProcessor() {
    }

    @Override
    public boolean process(Set<? extends TypeElement> set, RoundEnvironment roundEnvironment) {
        // 判断方法应该添加什么注解
        for (Element element : roundEnvironment.getElementsAnnotatedWith(Sensitive.class)) {

            javax.lang.model.element.Name methodName = element.getSimpleName();

            TypeElement typeElem = (TypeElement) element.getEnclosingElement();

            String typeName = typeElem.getQualifiedName().toString();
            astMojo.importIfAbsent(element, Convert.class);
            astMojo.importIfAbsent(element, SensitiveConverter.class);
            JCTree jcTree = trees.getTree(typeElem);

            jcTree.accept(new TreeTranslator() {

                @Override
                public void visitVarDef(JCTree.JCVariableDecl jcVariableDecl) {
                    List<JCTree.JCAnnotation> jcAnnotations = jcVariableDecl.mods.annotations;
                    try {
                        if (jcAnnotations != null && jcAnnotations.size() > 0) {
                            List<JCTree.JCAnnotation> nil = List.nil();
                            System.err.println(nil.toString());
                            System.err.println("===============");
                            for (JCTree.JCAnnotation jcAnnotation : jcAnnotations) {
                                if (Sensitive.class.getName().equals(jcAnnotation.getAnnotationType().type.tsym.toString())) {
                                    JCTree.JCAnnotation converterAnnotation = treeMaker.Annotation(
                                            astMojo.select(Convert.class.getName())
                                            , List.of(treeMaker.Assign(treeMaker.Ident(names.fromString("converter"))
                                                    , treeMaker.Select(treeMaker.Ident(names.fromString(SensitiveConverter.class.getSimpleName()))
                                                            , names.fromString("class")))));

                                    nil = nil.append(converterAnnotation);
                                } else {
                                    nil = nil.append(jcAnnotation);
                                }
                            }

                            jcVariableDecl.mods.annotations = nil;

                            System.err.println(nil.toString());
                        }
                    } catch (Exception e) {
                        System.err.println(e);
                    }

                    try {
                        super.visitVarDef(jcVariableDecl);
                    } catch (Exception e) {
                        System.err.println(e);
                    }

                }
            });
        }

        return true;
    }

    @Override
    public synchronized void init(ProcessingEnvironment processingEnv) {
        super.init(processingEnv);

        this.types = processingEnv.getTypeUtils();
        this.elements = processingEnv.getElementUtils();
        this.filer = processingEnv.getFiler();
        this.messager = processingEnv.getMessager();

        this.trees = JavacTrees.instance(processingEnv);
        Context context = ((JavacProcessingEnvironment) processingEnv).getContext();
        this.treeMaker = TreeMaker.instance(context);
        this.names = Names.instance(context);
        this.symtab = Symtab.instance(context);

        this.astMojo = new AstMojo(trees, treeMaker, names, symtab);
    }

}
```

```Java
public class AstMojo {

    private final JavacTrees trees;

    private final TreeMaker treeMaker;

    private final Names names;

    private final Symtab symtab;

    public AstMojo(JavacTrees trees, TreeMaker treeMaker, Names names, Symtab symtab) {
        this.trees = trees;
        this.treeMaker = treeMaker;
        this.names = names;
        this.symtab = symtab;
    }

    public void importIfAbsent(Element element, Class<?> importType) {
        JCTree.JCCompilationUnit compilationUnit = ((JCTree.JCCompilationUnit) trees.getPath(element).getCompilationUnit());
        boolean contains = false;
        for (JCTree.JCImport jcImport : compilationUnit.getImports()) {
            if (importType.getName().equals(jcImport.getQualifiedIdentifier().toString())) {
                contains = true;
                break;
            }
        }

        if (!contains) {
            JCTree.JCIdent jcIdent = treeMaker.Ident(names.fromString(importType.getPackage().getName()));
            Name className = names.fromString(importType.getSimpleName());
            JCTree.JCFieldAccess jcFieldAccess = treeMaker.Select(jcIdent, className);
            JCTree.JCImport jcImport = treeMaker.Import(jcFieldAccess, false);
            compilationUnit.defs = compilationUnit.defs.prepend(jcImport);
        }
    }

    public JCTree.JCExpression select(String path) {
        JCTree.JCExpression expression = null;
        int i = 0;
        for (String split : path.split("\\.")) {
            if (i == 0)
                expression = treeMaker.Ident(names.fromString(split));
            else {
                expression = treeMaker.Select(expression, names.fromString(split));
            }
            i++;
        }

        return expression;
    }

    public JCTree.JCIdent identFromString(String name) {
        return treeMaker.Ident(names.fromString(name));
    }
}

```

### 注解处理器生效
在项目的`resources` 下新增文件`META-INF/services/javax.annotation.processing.Processor`
内容如下
```text
net.reduck.sdp.processor.SensitiveProcessor
```

## GITHUB源码
[https://github.com/ReduckProject/reduck-sdp](https://github.com/ReduckProject/reduck-sdp)