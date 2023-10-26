### 动态条件查询 - where 1 = 1

### 是否存在 - select 1 from table limit 1

`findTop`

### 分页查询不查询总数，仅判断是否存在下一页 - limit row * page, (row + 1) 

Slice<User> findByLastname(String lastname, Pageable pageable);
