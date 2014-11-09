# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Cinema.create([
{
  name: 'Abreeza',
  latitude: 7.091450,
  longitude: 125.610936,
  status: 'active',
  fetcher: 'Abreeza',
  website: 'http://www.sureseats.com',
  address: 'Abreeza Ayala Business Park, J.P. Laurel Ave, Davao City'
},
{
  name: 'Gaisano Mall of Davao',
  latitude: 7.077843,
  longitude: 125.614033,
  status: 'active',
  fetcher: 'GaisanoMall',
  phone_number: '(082) 226-2244',
  website: 'https://www.facebook.com/gmallcinemas',
  address: 'J.P. Laurel Ave, Davao City'
},
{
  name: 'Gaisano Grand Mall',
  latitude: 7.012950,
  longitude: 125.490528,
  status: 'active',
  fetcher: 'GaisanoGrand',
  phone_number: '(082) 285-7579',
  website: 'https://www.facebook.com/gmallcinemas',
  address: 'Toril, Davao City'
},
{
  name: 'NCCC Mall',
  latitude: 7.063291,
  longitude: 125.593610,
  status: 'active',
  fetcher: 'NcccMall',
  phone_number: '(082) 305-0744',
  website: 'http://nccc.com.ph/main/page/cinema/',
  address: 'McArthur Highway corner Ma-a Road, Davao City'
},
{
  name: 'SM City Davao',
  latitude: 7.050202,
  longitude: 125.588078,
  status: 'active',
  fetcher: 'SmCityDavao',
  website: 'https://smcinema.com',
  address: 'Quimpo Boulevard, Ecoland, Davao City'
},
{
  name: 'SM Lanang Premiere',
  latitude: 7.098374,
  longitude: 125.630645,
  status: 'active',
  fetcher: 'SmLanang',
  website: 'https://smcinema.com',
  address: 'J.P. Laurel Ave, Lanang, Davao City'
},
{
  name: 'Victoria Plaza Mall',
  latitude: 7.086986,
  longitude: 125.611996,
  status: 'hidden',
  address: 'J.P. Laurel Avenue, Bajada, Davao City'
}
])