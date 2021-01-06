# install 
* intall nodeJS
* 配置淘宝镜像，否则可能下载chromium失败
`npm config set registry https://registry.npm.taobao.org`
* npm i --save puppeteer

# test.js
```
const puppeteer = require('puppeteer');

(async() => {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();

    await page.goto('https://news.sina.com.cn/', {waitUntil: 'networkidle2'});
    await page.screenshot({ path: "my_screenshot.png", fullPage: true })

    // await page.pdf({path: 'page.pdf', format: 'A4'});

    await browser.close();
})();
```