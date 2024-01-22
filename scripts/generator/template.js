

module.exports = (description, external_url, image, name, attributes) => `{
    "description": "${description}",
    "external_url": "${external_url}",
    "image": "${image}",
    "name": "${name}",
    "attributes": ${attributes}
}`