const dotenv = require('dotenv');
dotenv.config();

const fs = require('fs');
const { faker } = require('@faker-js/faker');
const { v4: uuidv4 } = require('uuid');
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;

const supabaseSchema = "public";
const supabase = createClient(supabaseUrl, supabaseKey);

function readFromJson(file) {
    if (!fs.existsSync(file)) {
        throw new Error(`File ${file} does not exist`);
    }
    const data = fs.readFileSync(file, 'utf8');
    return JSON.parse(data);
}

function readFromCSVColumn(file, column_name) {
    if (!fs.existsSync(file)) {
        throw new Error(`File ${file} does not exist`);
    }
    const data = fs.readFileSync(file, 'utf8').split('\n');
    const csvColumnData = data.map(row => (row.split(',')[column_name]).replace('\r', ''));
    return csvColumnData.slice(1);
}

function readFromCSVToJson(file) {
    if (!fs.existsSync(file)) {
        throw new Error(`File ${file} does not exist`);
    }
    const data = fs.readFileSync(file, 'utf8').split('\n');
    // convert into json
    const headers = data[0].replace('\r', '').split(',');
    const rows = data.slice(1);
    const jsonData = rows.map(row => {
        const rowValues = row.replace('\r', '').split(',');
        const rowObj = {};
        for (let i = 0; i < headers.length; i++) {
            rowObj[headers[i]] = rowValues[i];
        }
        return rowObj;
    });
    return jsonData;
}

function readFromTxt(file) {
    if (!fs.existsSync(file)) {
        throw new Error(`File ${file} does not exist`);
    }
    const data = fs.readFileSync(file, 'utf8').split('\n').map(url => url.replace('\r', '')).filter(url => url !== '');
    return data;
}

function titleCase(str) {
    return str.toLowerCase().split(' ').map(function (word) {
        return word.replace(word[0], word[0].toUpperCase());
    }).join(' ');
}

function clean_photo_url(url) {
    return url.replace(/(\r\n|\n|\r)/gm, "");
}

const config = readFromJson('../config.json');
console.log('Config:', config);
function getConfig(key) {
    if (config[key] === undefined) {
        throw new Error(`Key ${key} not found in config.json`);
    }
    return config[key];
}

const masters = readFromCSVColumn('data/masters_seed_data.csv', 1);
const universities = readFromCSVToJson('data/universities_seed_data.csv');
const languages = readFromCSVColumn('data/languages_seed_data.csv', 2);
const random_locations = readFromCSVToJson('data/us_random_locations.csv');

const room_category_photos = getConfig('room_images');

const person_types = ["Ambivert", "Extrovert", "Introvert"];
const user_habits = ["Regular", "Occasional", "Rarely", "Never"];
const food_habits = ["Vegan", "Vegetarian", "Pescatarian", "Eggetarian", "Non-Vegetarian"];
const cleanliness_habits = ["Very Clean", "Clean", "Average", "Messy", "Very Messy"];
const cooking_skill = ["Newbie", "Intermediate", "Chef"];
const cleanliness_habit = ["Messy", "Decently Clean", "Very Clean", "Obsessively Clean"];
const user_room_type = ["Anything", "Private", "Shared", "Flex"];
const user_flatmates_gender_prefs = ["Male", "Female", "Mix"];
const user_intake = ["Spring", "Fall", "Summer", "Winter"];
const user_intake_year = [2021, 2022, 2023, 2024, 2025, 2026];

const marketplace_items = getConfig('marketplace_items');
const marketplace_categories = readFromCSVToJson('data/marketplace_categories_seed_data.csv');

function createRandomUser() {
    const gender = faker.person.sexType();
    return {
        id: uuidv4(),
        created_at: new Date(),
        gender: titleCase(gender),
        full_name: faker.person.fullName({ sex: gender }),
        email: faker.internet.email(),
        phone: faker.phone.number(),
        profile_image: faker.image.personPortrait({ sex: gender }),
        city: faker.location.city(),
        selected_course_name: faker.helpers.arrayElement(masters),
        undergrad_college_name: faker.helpers.arrayElement(universities).title,
        birth_date: faker.date.past(),
        person_type: faker.helpers.arrayElement(person_types),
        prefs: {},
        primary_lang: faker.helpers.arrayElement(languages),
        other_lang: faker.helpers.arrayElement(languages),
        work_experience: faker.number.int({ max: 6 }),
        smoking_habit: faker.helpers.arrayElement(user_habits),
        habits: {},
        hobbies: faker.lorem.sentences({ min: 1, max: 3 }),
        drinking_habit: faker.helpers.arrayElement(user_habits),
        food_habit: faker.helpers.arrayElement(food_habits),
        cooking_skill: faker.helpers.arrayElement(cooking_skill),
        cleanliness_habit: faker.helpers.arrayElement(cleanliness_habits),
        state: faker.location.state(),
        bio: faker.person.bio(),
        room_type: faker.helpers.arrayElement(user_room_type),
        flatmates_gender_prefs: faker.helpers.arrayElement(user_flatmates_gender_prefs),
        country: faker.location.country(),
        user_deleted: false,
        user_deleted_date: null,
        intake_period: faker.helpers.arrayElement(user_intake),
        intake_year: faker.helpers.arrayElement(user_intake_year),
        has_roommate_found: false,
        user_data_completed: true,
        college: faker.helpers.arrayElement(universities).title,
    };
}


async function seedUsers(numSeedUsers) {
    const users = faker.helpers.multiple(createRandomUser, { count: numSeedUsers });
    try {
        for (const user of users) {
            const { data, error } = await supabase.schema(supabaseSchema).from('user_details').insert(user);
            if (error) {
                console.error('(Supabase) Error seeding users:', error);
                console.error('Error prone user: ', user);
            } else {
                console.log('User seeded successfully - ', user.full_name);
            }
        }
    } catch (error) {
        console.error('Error seeding users:', error);
    }
}

const amenities_available = [
    DRYER = 'has_dryer',
    WASHING_MACHINE = 'has_washing_machine',
    DISHWASHER = 'has_dishwasher',
    PARKING = 'has_parking',
    GYM = 'has_gym',
    POOL = 'has_pool',
    BALCONY = 'has_balcony',
    PATIO = 'has_patio',
    AC = 'has_ac',
    GAS = 'has_gas',
    SEMI_FURNISHED = 'has_semi_furnished',
    HEATER = 'has_heater',
    FURNISHED = 'has_furnished',
]


function createRandomSublet(photos) {
    const amenities = {};
    amenities_available.forEach(amenity => {
        amenities[amenity] = faker.datatype.boolean();
    });
    const random_location = faker.helpers.arrayElement(random_locations);
    const current_time = faker.date.recent().getTime();
    const start_date = faker.date.future().getTime();
    const end_date = faker.date.future().getTime();
    return {
        id: current_time,
        room_description: faker.lorem.sentences({ min: 1, max: 3 }),
        roommate_description: faker.lorem.sentences({ min: 1, max: 3 }),
        roommate_gender_pref: titleCase(faker.person.sexType()),
        rent: faker.finance.amount(),
        photos: photos,
        amenities_available: amenities,
        room_type: faker.helpers.arrayElement(user_room_type),
        is_available: true,
        user_id: uuidv4(),
        start_date: start_date,
        end_date: end_date,
        beds: faker.number.int({ min: 1, max: 3 }),
        baths: faker.number.int({ min: 1, max: 3 }),
        location: "POINT(" + random_location.lat + " " + random_location.lon + ")",
        address: `${faker.location.streetAddress({ useFullAddress: true })}, ${faker.location.city()}, ${faker.location.state()}, ${faker.location.country()}`,
    };
}


function createRandomApartment(photos) {
    const amenities = {};
    amenities_available.forEach(amenity => {
        amenities[amenity] = faker.datatype.boolean();
    });
    const random_location = faker.helpers.arrayElement(random_locations);
    const current_time = faker.date.recent().getTime();
    const start_date = faker.date.future().getTime();
    const end_date = faker.date.future().getTime();
    return {
        id: current_time,
        apartment_description: faker.lorem.sentences({ min: 1, max: 3 }),
        rent: faker.finance.amount(),
        photos: photos,
        amenities_available: amenities,
        is_available: true,
        user_id: uuidv4(),
        start_date: start_date,
        end_date: end_date,
        beds: faker.number.int({ min: 1, max: 3 }),
        baths: faker.number.int({ min: 1, max: 3 }),
        location: "POINT(" + random_location.lat + " " + random_location.lon + ")",
        address: `${faker.location.streetAddress({ useFullAddress: true })}, ${faker.location.city()}, ${faker.location.state()}, ${faker.location.country()}`,
    };
}

function getAllRoomPhotos() {
    const room_photos_folder = 'data/room_photos';
    if (!fs.existsSync(room_photos_folder)) {
        throw new Error(`Folder ${room_photos_folder} does not exist`);
    }
    const room_photos = fs.readdirSync(room_photos_folder);
    const room_photos_map = {};
    console.log(room_photos);
    room_photos.forEach(photo => {
        const photo_name = photo.replace("_urls.txt", "");
        console.log(photo_name);
        if (!room_category_photos.includes(photo_name)) {
            return;
        }
        room_photos_map[photo_name] = readFromTxt(`${room_photos_folder}/${photo}`);
    });
    if (Object.keys(room_photos_map).length === 0) {
        throw new Error('No room photos found');
    }
    for (const [key, value] of Object.entries(room_photos_map)) {
        if (value.length === 0) {
            throw new Error(`No photos found for ${key}`);
        }
    }
    return room_photos_map;
}

async function seedRooms({
    isApartment = false,
    itemCount = 100,
}) {
    const photos = getAllRoomPhotos();
    const sublets = []
    for (let i = 0; i < itemCount; i++) {
        const numOfImages = faker.number.int({ min: 3, max: 6 });
        const selectedPhotos = [];
        for (let i = 0; i < numOfImages; i++) {
            const randomRoomType = faker.helpers.arrayElement(Object.keys(photos));
            const randomPhoto = faker.helpers.arrayElement(photos[randomRoomType]);
            selectedPhotos.push(randomPhoto);
        }
        if (selectedPhotos.length === 0) {
            throw new Error('No photos found');
        }
        if (isApartment) {
            sublets.push(createRandomApartment(selectedPhotos));
        } else {
            sublets.push(createRandomSublet(selectedPhotos));
        }
    }
    try {
        for (const sublet of sublets) {
            const { data, error } = await supabase.schema(supabaseSchema).from(
                isApartment ? 'apartments' : 'sublets'
            ).insert(sublet);
            if (error) {
                console.error(`Error seeding ${isApartment ? 'apartments' : 'sublets'}:`, error);
                console.error('Error prone sublet: ', sublet);
            } else {
                console.log('Sublet seeded successfully - ', sublet.id);
            }
        }
    } catch (error) {
        console.error('Error seeding sublets:', error);
    }
}

function getAllMarketplacePhotos() {
    const marketplace_photos_folder = 'data/marketplace_photos';
    if (!fs.existsSync(marketplace_photos_folder)) {
        throw new Error(`Folder ${marketplace_photos_folder} does not exist`);
    }
    const marketplace_photos = fs.readdirSync(marketplace_photos_folder);
    const marketplace_photos_map = {};
    marketplace_photos.forEach(photo => {
        const photo_name = photo.replace("_urls.txt", "");
        if (!marketplace_items.includes(photo_name)) {
            throw new Error(`Photo name ${photo_name} not found in marketplace_items`);
        }
        marketplace_photos_map[photo_name] = readFromTxt(`${marketplace_photos_folder}/${photo}`);
    });
    if (Object.keys(marketplace_photos_map).length === 0) {
        throw new Error('No marketplace photos found');
    }
    for (const [key, value] of Object.entries(marketplace_photos_map)) {
        if (value.length === 0) {
            throw new Error(`No photos found for ${key}`);
        }
    }
    return marketplace_photos_map;
}

function createRandomMarketplace() {
    const title = `${faker.commerce.productAdjective()()} ${titleCase(faker.helpers.arrayElement(marketplace_items))}`;
    const description = faker.commerce.productDescription();
    const location = faker.helpers.arrayElement(random_locations);
    const current_time = faker.date.recent().getTime();
    const start_date = faker.date.future().getTime();
    const end_date = faker.date.future().getTime();
    const numOfImges = faker.number.int({ min: 2, max: 4 });
    const category = faker.helpers.arrayElement(marketplace_categories);
    return {
        id: current_time,
        name: title,
        created_at: current_time,
        category: {
            id: category.id,
            name: category.name,
        },
        description: description,
        photos: photos,
        price: faker.finance.amount({ dec: 0 }),
        link: {},
        period: {
            period_from: start_date,
            period_till: end_date,
        },
        is_available: true,
        user_id: uuidv4(),
        location: "POINT(" + location.lat + " " + location.lon + ")",
        address: `${faker.location.streetAddress({ useFullAddress: true })}, ${faker.location.city()}, ${faker.location.state()}, ${faker.location.country()}`,
    };

}

async function seedMarketplaces(numOfMarketplaceItems) {
    try {
        const marketplacePhotos = getAllMarketplacePhotos();
        const marketplaceItemsArray = Object.keys(marketplacePhotos);
        const numMarketplaceForEachItem = Math.ceil(numOfMarketplaceItems / marketplaceItemsArray.length);
        for (let i = 0; i < numMarketplaceForEachItem; i++) {
            const marketplaceCategory = faker.helpers.arrayElement(marketplaceItemsArray);
            const photos = marketplacePhotos[marketplaceCategory];
            const marketplace = createRandomMarketplace(photos);
            const { data, error } = await supabase.schema(supabaseSchema).from('marketplaces').insert(marketplace);
            if (error) {
                console.error('Error seeding marketplaces:', error);
                console.error('Error prone marketplace: ', marketplace);
            } else {
                console.log('Marketplace seeded successfully - ', marketplace.id);
            }
        }
    } catch (error) {
        console.error('Error seeding marketplaces:', error);
    }
}

async function seed() {

    const canSeedUsers = getConfig('seed_users');
    const canSeedSublets = getConfig('seed_sublets');
    const canSeedApartments = getConfig('seed_apartments');
    const canSeedMarketplaces = getConfig('seed_marketplaces');

    const numSeedUsers = getConfig('seed_user_items');
    const numSeedRooms = getConfig('seed_room_items');
    const numSeedMarketplaces = getConfig('seed_marketplace_items');

    if (canSeedUsers) {
        await seedUsers(numSeedUsers);
    }
    if (canSeedSublets) {
        await seedRooms({ isApartment: false, itemCount: numSeedRooms });
    }
    if (canSeedApartments) {
        await seedRooms({ isApartment: true, itemCount: numSeedRooms });
    }
    if (canSeedMarketplaces) {
        await seedMarketplaces(numSeedMarketplaces);
    }
}

seed();