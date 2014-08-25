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
  fetcher: 'Abreeza'
},
{
  name: 'Gaisano Mall of Davao',
  latitude: 7.077843,
  longitude: 125.614033,
  status: 'active'
},
{
  name: 'Gaisano Grand Mall',
  latitude: 7.012950,
  longitude: 125.490528,
  status: 'active'
},
{
  name: 'NCCC Mall',
  latitude: 7.063291,
  longitude: 125.593610,
  status: 'active',
  fetcher: 'NcccMall'
},
{
  name: 'SM City Davao',
  latitude: 7.050202,
  longitude: 125.588078,
  status: 'active',
  fetcher: 'SmCityDavao'
},
{
  name: 'SM Lanang Premiere',
  latitude: 7.098374,
  longitude: 125.630645,
  status: 'active',
  fetcher: 'SmLanang'
},
{
  name: 'Victoria Plaza Mall',
  latitude: 7.086986,
  longitude: 125.611996,
  status: 'hidden'
}
])