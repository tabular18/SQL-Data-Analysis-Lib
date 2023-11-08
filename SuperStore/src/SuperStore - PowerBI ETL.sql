/*Target Tables:
Orders - one row per unique product ID per order ID
People - one row per Region
Locations - one row per Postal Code
Categories - one row per sub-category
Product List - one row per unique product ID
Returned - one row per order ID
*/


/*
Orders

- Rename Country/Region > Country
- cast datatypes
- replace postal code nulls with UNKNOWN
- Merged State, City column

*/



/*
Product ID is NOT unique, so generaete new unique ID using an index
source orders
Create unique product ID using product ID and index
*/