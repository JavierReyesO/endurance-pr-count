const puppeteer = require('puppeteer');

(async () => {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();

    // Cambiar la URL para que apunte al servidor local en lugar de usar file://
    const fileUrl = 'http://localhost:8080/index.html'; // Cambia la ruta al servidor local

    // Cargar la página
    await page.goto(fileUrl, { waitUntil: 'networkidle0' });

    // Esperar a que el contenido dinámico se haya cargado completamente
    await page.waitForFunction(() => {
        return document.querySelector('#prCount').innerText !== 'Loading...';
    });

    // Tomar la captura
    await page.screenshot({ path: 'preview-image.png', fullPage: true });

    await browser.close();
})();

