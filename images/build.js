const YAML = require('yaml')
const fs = require('fs');
const Twig = require("twig");
const util = require('util');
const child_process = require('child_process');
const fg = require('fast-glob');
const renderFile = util.promisify(Twig.renderFile);
let config = YAML.parse(fs.readFileSync(__dirname + '/build.yaml', 'utf8'));
const command = process.argv[2];
const tag = process.argv[3] || null;

const run = async() => {
    config = await prepareConfig(config);
    if (command === 'build') {
        for (let image of config.images) {
            if (tag && !image.buildTags.includes(tag)) {
                continue;
            }
    
            for (let tagName of Object.keys(image.tags)) {
                let tag = image.tags[tagName];
                let cleanupList = [];
    
                // Render templates
                let variables = {...config.variables, ... image.variables, ... tag};
                for (let fileName of Object.keys(image.templates)) {
                    let saveFile = image.templates[fileName];
                    let content = await renderFile(fileName, variables);
                    fs.writeFileSync(saveFile, content);
                    cleanupList.push(saveFile);
                }

                // Build that image
                await exec('docker', ['build', '-t', `${image.image}:${tagName}`,  `-f`, image.dockerFile, image.context], `Building ${image.image}:${tagName}`);

                // Cleanup rendered files
                for (let file of cleanupList) {
                    fs.unlinkSync(file);
                }
            }
        }
    }

    if (command === 'push') {
        for (let image of config.images) {
            if (tag && !image.buildTags.includes(tag)) {
                continue;
            }

            for (let tagName of Object.keys(image.tags)) {
                await exec('docker', ['push', `${image.image}:${tagName}`], `Pushing ${image.image}:${tagName}`);
            }
        }
    }
};

const exec = (command, args, prefix) => {
    return new Promise((resolve, reject) => {
        const child = child_process.spawn(command, args);

        child.stdout.on('data', (chunk) => {
            process.stdout.write(`${prefix}: ${chunk}`);
        });

        child.stderr.on('data', (chunk) => {
            console.log(`Stderr: ${chunk}`);
        });

        child.on('close', (code) => {
            if (code === 0) {
                resolve();
            } else {
                reject(child);
            }
        });
    });
};

const prepareConfig = async (config) => {
    config = addDefaults(config);
    const entries = await fg(config.includes, { dot: false });

    for (let otherConfig of entries) {
        otherConfig = addDefaults(YAML.parse(fs.readFileSync(__dirname + '/' + otherConfig, 'utf8')));
        config.images = config.images.concat(otherConfig.images);
        config.variables = {... config.variables, ...otherConfig.variables};
    }

    return config;
};

const addDefaults = (config) => {
    if (config.includes === undefined) {
        config.includes = [];
    }

    if (config.variables === undefined) {
        config.variables = [];
    }

    if (config.images === undefined) {
        config.images = [];
    }

    for (let image of config.images) {
        if (image.buildTags === undefined) {
            image.buildTags = [];
        }

        if (image.variables === undefined) {
            image.variables = [];
        }

		if (image.templates === undefined) {
			image.templates = [];
		}
    }

    return config;
};

run();
