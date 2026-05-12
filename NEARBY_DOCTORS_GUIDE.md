# Nearby Doctors Feature - Integration Guide

## Overview

The Nearby Doctors feature allows patients to find healthcare professionals in their vicinity using geolocation services. This feature integrates browser geolocation API with backend distance calculations.

## Features

✅ **Default Location (Hyderabad)**: Automatically shows doctors near Hyderabad (17.3850°N, 78.4867°E)  
✅ **GPS Integration**: Enable precise GPS location for your current position  
✅ **Location Persistence**: Saves patient location to backend for future searches  
✅ **Distance Calculation**: Uses Haversine formula for accurate km distance  
✅ **Specialization Filtering**: Find doctors by medical specialty  
✅ **Adjustable Radius**: Search within 1-50km radius  
✅ **Availability Status**: Shows which doctors are currently available  
✅ **Responsive Design**: Works on desktop and mobile devices  

## Architecture

### Backend Changes

#### Models
- **User Model**: Added `latitude` and `longitude` fields for patient location storage
- **Doctor Model**: Already had location fields (`latitude`, `longitude`, `available`)

#### Services
- **DoctorService** (NEW)
  - `findNearbyDoctors()` - Find all available doctors near a location
  - `findNearbyDoctorsBySpecialization()` - Filter doctors by specialty
  - `calculateDistance()` - Haversine formula for distance calculation

#### Controllers  
- **DoctorController** - Extended with new endpoints:
  - `GET /api/doctor/nearby` - Find nearby doctors
  - `GET /api/doctor/nearby/specialization` - Find nearby doctors by specialty
  - `PUT /api/doctor/location` - Save patient location
  - `GET /api/doctor/location` - Retrieve saved patient location

### Frontend Changes

#### Services
- **api.js** - Added doctor location API methods:
  ```javascript
  doctorAPI.findNearby(latitude, longitude, radiusKm)
  doctorAPI.findNearbyBySpecialization(latitude, longitude, specialization, radiusKm)
  doctorAPI.updateUserLocation(latitude, longitude)
  doctorAPI.getUserLocation()
  ```

#### Components
- **NearbyDoctors.jsx** (NEW)
  - Uses browser Geolocation API
  - Displays nearby doctors in card format
  - Allows filtering by specialty and radius
  - Shows distance to each doctor

#### Pages
- **PatientDashboard.jsx** - Integrated NearbyDoctors component
- **PatientSidebar.jsx** - Added navigation item for "Find Nearby Doctors"

### Database Changes
- **schema.sql** - Added 16 sample doctors with realistic locations in NYC area
- **users table** - Added `latitude` and `longitude` columns with location index

## API Endpoints

### Find Nearby Doctors
```
GET /api/doctor/nearby?latitude=40.7128&longitude=-74.0060&radiusKm=5
```

**Parameters:**
- `latitude` (Double, required): Patient's latitude
- `longitude` (Double, required): Patient's longitude  
- `radiusKm` (Double, optional): Search radius in kilometers (default: 5km)

**Response:**
```json
{
  "success": true,
  "message": "Nearby doctors found",
  "data": [
    {
      "id": 1,
      "name": "Dr. Rajesh Kumar",
      "specialization": "Cardiologist",
      "latitude": 40.7145,
      "longitude": -74.0080,
      "available": true,
      "distanceKm": "0.23"
    }
  ]
}
```

### Find Nearby Doctors by Specialization
```
GET /api/doctor/nearby/specialization?latitude=40.7128&longitude=-74.0060&specialization=Cardiologist&radiusKm=5
```

**Parameters:**
- `latitude` (Double, required): Patient's latitude
- `longitude` (Double, required): Patient's longitude
- `specialization` (String, required): Medical specialty to filter by
- `radiusKm` (Double, optional): Search radius in kilometers (default: 5km)

### Update Patient Location
```
PUT /api/doctor/location
Content-Type: application/json
Authorization: Bearer {token}

{
  "latitude": 40.7128,
  "longitude": -74.0060
}
```

### Get Patient Location
```
GET /api/doctor/location
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "Location retrieved",
  "data": {
    "latitude": 40.7128,
    "longitude": -74.0060
  }
}
```

## How to Use

### For Patients

1. **Access Feature**: Navigate to `Patient Dashboard → Find Nearby Doctors`

2. **Default Location**: The page automatically loads with **Hyderabad** as the default location
   - Shows doctors near Hyderabad (17.3850°N, 78.4867°E)
   - No action needed - searches work immediately

3. **Enable GPS (Optional)**: 
   - Click **"Enable GPS"** button to use your precise current location
   - Browser will request location permission
   - Choose "Allow" to enable geolocation
   - Location is automatically saved to your profile
   - Status shows: GPS Enabled with your coordinates

4. **Set Search Parameters**:
   - **Search Radius**: Select how far you want to search (1-50 km)
   - **Specialization**: Filter by doctor specialty or search all doctors

5. **Search**: Click "Search Doctors" button

6. **View Results**: See nearby doctors sorted by distance
   - Cards show doctor name, specialty, distance, and availability
   - Available doctors marked with green status badge
   - Shows coordinates of each doctor

7. **Book Appointment**: Click "Book Appointment" on doctor card (links to booking flow)

### Location Modes

| Mode | How It Works | When Used |
|------|---|---|
| **Hyderabad Default** | Uses fixed Hyderabad coordinates (17.3850, 78.4867) | When GPS is not enabled or denied |
| **GPS Enabled** | Uses your device's precise GPS location | When you click "Enable GPS" and grant permission |
| **Saved Location** | Uses previously saved location from your profile | When GPS attempts to use backend cached location |

### Distance Formula

The feature uses the **Haversine formula** to calculate great-circle distance between two points:

```
a = sin²(Δlat/2) + cos(lat1) * cos(lat2) * sin²(Δlon/2)
c = 2 * atan2(√a, √(1−a))
d = R * c
```

Where:
- R = Earth's radius (6,371 km)
- Δlat = latitude difference
- Δlon = longitude difference

## Sample Doctors

The database includes 16 sample doctors across multiple specialties in **Hyderabad** area:

**All doctors are centered around Hyderabad (17.3850°N, 78.4867°E) with slight coordinate variations:**

| Specialty | Doctors | Count |
|---|---|---|
| Cardiologist | Dr. Rajesh Kumar, Dr. Priya Sharma | 2 |
| General Practitioner | Dr. Amit Patel, Dr. Neha Singh | 2 |
| Dermatologist | Dr. Vivek Desai, Dr. Anjali Reddy | 2 |
| Orthopedic Surgeon | Dr. Rohan Gupta, Dr. Meera Nair | 2 |
| Neurologist | Dr. Suresh Iyer, Dr. Ananya Verma | 2 |
| Pediatrician | Dr. Karthik Rao, Dr. Deepika Mishra | 2 |
| Psychiatrist | Dr. Vikram Yadav, Dr. Pooja Kapoor | 2 |
| Ophthalmologist | Dr. Arun Bhat, Dr. Shreya Nambiar | 2 |
| ENT | Dr. Sameer Khan, Dr. Ritika Bose | 2 |

## Geolocation Permissions

### GPS is Optional
- ✅ **Works without GPS**: Default Hyderabad location allows immediate searches
- ✅ **GPS available**: Click "Enable GPS" for precise location (requires browser permission)
- ❌ **GPS denied**: Falls back gracefully to Hyderabad default

### Browser Support
- ✅ Chrome, Firefox, Safari, Edge (modern versions)
- ✅ Mobile browsers (iOS Safari, Chrome Mobile, Firefox Mobile)
- ℹ️ Browser requests permission when "Enable GPS" is clicked (not on page load)
- ℹ️ HTTPS or localhost required for GPS (not for default Hyderabad search)

### Privacy & Security
- Location permission is **optional** - users not required to grant it
- GPS access is **opt-in** - only when "Enable GPS" button is clicked
- Location data is stored server-side for convenience (with user consent)
- Users can refresh location at any time
- Hyderabad default location doesn't require any permissions

### Location Flow
```
Page Load
    ↓
Use Hyderabad (17.3850, 78.4867) Default
    ↓
User can search immediately
    ↓
User clicks "Enable GPS" → Browser requests permission
    ↓
If Allow → Use precise GPS location
If Deny → Continue using Hyderabad default
```

## Testing the Feature

### Local Testing
```bash
# Start the application
npm run dev  # Frontend on port 5174
java -jar backend/target/healthcare-chat-assistant-1.0.0.jar  # Backend on port 8081

# Navigate to: http://localhost:5174/dashboard?section=nearby
```

### Test Coordinates (Hyderabad)
Use these Hyderabad coordinates for testing:
- **Default Center**: 17.3850, 78.4867 (City Center)
- **HITEC City**: 17.3558, 78.3346 (IT Hub)
- **Hiranandani Estate**: 17.3809, 78.3581 (Residential)
- **Gachibowli**: 17.4410, 78.3765 (Business District)
- **Dilsukhnagar**: 17.3724, 78.5178 (Commercial)

### Test Scenarios
1. **Default Load**: Page loads → See Hyderabad doctors automatically
2. **Enable GPS**: Click "Enable GPS" → Grant permission → See your location
3. **Deny GPS**: Click "Enable GPS" → Deny permission → Fallback to Hyderabad
4. **Search All Doctors**: Leave specialization blank → See all available doctors
5. **Filter by Specialty**: Select a specialty → See filtered results
6. **Adjust Radius**: Change radius (1km, 5km, 10km, 20km) → See results update
7. **Update Location**: Use "Refresh GPS" button → Test location persistence

## Adding More Doctors

To add new doctors to the system:

```sql
INSERT INTO doctors (name, specialization, latitude, longitude, available) 
VALUES 
  ('Dr. Name', 'Specialization', 40.7128, -74.0060, TRUE),
  ('Dr. Name 2', 'Specialization', 40.7145, -74.0080, TRUE);
```

**Available Specializations**: Cardiologist, General Practitioner, Dermatologist, Orthopedic Surgeon, Neurologist, Pediatrician, Psychiatrist, Ophthalmologist, ENT, Dentist

## Common Issues & Solutions

### Doctors Not Showing Up
**Problem**: Feature shows "no doctors found" on default load  
**Solution**:
- Verify sample doctors are inserted in database: `SELECT * FROM doctors;`
- Expected: 16 doctors with Hyderabad coordinates (17.38-17.39 latitude, 78.48-78.49 longitude)
- Check search radius includes doctor locations
- Default radius is 5km, which should cover all sample doctors

### GPS Not Working
**Problem**: "Enable GPS" button doesn't get location  
**Solution**:
- Ensure browser supports Geolocation API (all modern browsers)
- Check browser privacy settings for location permission
- Try clearing cache/cookies of the site
- GPS requires HTTPS (except on localhost:5173/5174)
- Mobile: Ensure device location services are enabled globally
- Mobile: App/browser has permission to access location

### Location Permission Not Requested
**Problem**: Browser doesn't show GPS permission dialog when clicking "Enable GPS"  
**Solution**:
- This is normal on localhost with allowed permissions already granted
- Check browser settings: Settings → Privacy & Security → Site Settings → Location
- If site is already allowed, no dialog appears
- Reset permissions for localhost and try again
- Use incognito/private mode to reset permissions

### Hyderabad Default Not Showing
**Problem**: Page shows "Loading..." but no default doctors appear  
**Solution**:
- Check backend is running on port 8081: `curl http://localhost:8081/api/doctor/nearby?latitude=17.3850&longitude=78.4867&radiusKm=5`
- Verify database migration ran: `SELECT COUNT(*) FROM doctors;`
- Check browser console for API errors (F12 → Console tab)
- Try refreshing the page
- Backend logs should show the API call

### Wrong Distance Calculations
**Problem**: Distances seem incorrect  
**Solution**:
- Verify latitude/longitude formats (decimal degrees, not DMS)
- Sample doctors use coordinates around 17.38-17.39 latitude
- Ensure patient location is also in Hyderabad area for accuracy
- Haversine formula is accurate within ±0.5% of true distance
- Test with known API call: `GET /api/doctor/nearby?latitude=17.3850&longitude=78.4867&radiusKm=10`

## Future Enhancements

Potential improvements for next phases:
- [ ] Ratings & reviews for doctors
- [ ] Real-time doctor availability from calendar
- [ ] Integration with Google Maps API for directions
- [ ] Favorite doctors list
- [ ] Doctor bio and qualifications display
- [ ] Appointment availability calendar
- [ ] Payment integration for bookings
- [ ] Doctor profile pages with patient reviews

## Files Modified/Created

### Backend
- ✅ `src/main/java/com/healthcare/model/User.java` - Added location fields
- ✅ `src/main/java/com/healthcare/service/DoctorService.java` - NEW
- ✅ `src/main/java/com/healthcare/controller/DoctorController.java` - Added endpoints

### Frontend
- ✅ `src/services/api.js` - Added doctor location APIs
- ✅ `src/components/patient/NearbyDoctors.jsx` - NEW
- ✅ `src/components/patient/PatientSidebar.jsx` - Added navigation
- ✅ `src/pages/PatientDashboard.jsx` - Integrated component

### Database
- **schema.sql** - Added users location columns, doctors table with 16 doctors in Hyderabad area, and sample data

## Support

For issues or questions:
1. Check this guide's troubleshooting section
2. Review server logs: `logs/healthcare-chat.log`
3. Test with sample coordinates provided
4. Check browser console for client-side errors
