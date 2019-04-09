var Twig = require('twig');

Twig.renderFile(process.argv[2], process.argv[3] ? JSON.parse(process.argv[3]) : {}, (err, html) => {
    if (err) {
        console.log(err);
        process.exit(1);
    }

    console.log(html);
});