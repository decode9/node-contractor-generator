const fs = require('fs')
const template = require('./template')
const dir = './METADATA';

const createMetadata = async (amount = 1, description, external_url, image, name, attributes) => {

    if (!fs.existsSync(dir)) fs.mkdirSync(dir)

    for (let i = 1; i <= amount; i++) {
        for(const attribute of attributes){
            if(attribute?.trait_type === 'Pass N#') attribute.value = i
            if(attribute?.trait_type === 'Published') attribute.value = new Date().getTime()
        }
        const nftMetadata = template(description, external_url, image, name, JSON.stringify(attributes))
        fs.writeFileSync(`${dir}/${i}`, nftMetadata)
        console.log(`File #${i} is created`)
    }
}

createMetadata(15, 'description', 'external_url', 'image', 'name', [{ trait_type: 'Author', value: 'decode9' }, { trait_type: 'Pass N#', value: 1 }, { display_type: 'date', trait_type: 'Published', value: new Date().getTime() }])