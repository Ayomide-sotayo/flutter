import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Updated color scheme for PopaRide
const Color primaryColor = Color(0xFF3D82F7);
const Color accentColor = Color(0xFF1A56CC);
const Color backgroundColor = Color(0xFFF8FAFF);
const Color lightGrey = Color(0xFFEEF2F9);
const Color darkText = Color(0xFF2A3642);

class SearchRidesPage extends StatefulWidget {
  const SearchRidesPage({Key? key}) : super(key: key);

  @override
  State<SearchRidesPage> createState() => _SearchRidesPageState();
}

class _SearchRidesPageState extends State<SearchRidesPage>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  // Default position; will update with the user's current position.
  LatLng _initialPosition = const LatLng(37.42796133580664, -122.085749655962);
  final List<Marker> _markers = [];
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  String _selectedRideType = 'Casual';
  bool _showTopSearch = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Get current location on startup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  // Request location permissions, then get the current location
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled.")),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Reverse-geocode the coordinates to obtain an address
    String address = 'Your Location';
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        address = '${place.street}, ${place.locality}';
      }
    } catch (e) {
      address = 'Your Location';
    }

    // Update the marker, map center, and the "From" text field with the location
    setState(() {
      final currentPos = LatLng(position.latitude, position.longitude);
      _markers.clear();
      _markers.add(
        Marker(
          point: currentPos,
          width: 40,
          height: 40,
          child: _buildCustomMarker(),
        ),
      );
      _initialPosition = currentPos;
      _fromController.text = address;
      _mapController.move(currentPos, 15);
    });
  }

  Widget _buildCustomMarker() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(Icons.location_on_rounded, color: primaryColor, size: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Map layer using Mapbox
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialPosition,
                initialZoom: 14.0,
                interactionOptions: const InteractionOptions(
                  enableMultiFingerGestureRace: true,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}',
                  additionalOptions: {
                    'accessToken':
                        'pk.eyJ1IjoicHJvZmVzc2V1cjEyIiwiYSI6ImNtOWk5b3MwMjAwZTIybHM1Y2ZjN2hpZjEifQ.mh7nmriuILklVdIYN8xefA', // Replace with your actual token
                    'id': 'mapbox/streets-v11',
                  },
                  userAgentPackageName: 'com.example.poparide',
                  tileProvider: NetworkTileProvider(),
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
          ),
          // UI layers
          _buildHamburgerMenu(),
          _buildTopSearchBar(),
          _buildBottomSheet(),
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      right: 20,
      bottom: 175,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Location button: re-center the map on the current position
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _mapController.move(_initialPosition, 15),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.gps_fixed, color: accentColor, size: 26),
                ),
              ),
            ),
          ),
          // Layers button (for future layers feature)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Map layers coming soon!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: accentColor,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.layers, color: accentColor, size: 26),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.75,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.1),
              blurRadius: 25,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 15,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildDrawerItem(Icons.directions_car_rounded, 'My Rides'),
                  _buildDrawerItem(Icons.history_rounded, 'Rides History'),
                  _buildDrawerItem(
                    Icons.credit_card_rounded,
                    'Payment Methods',
                  ),
                  _buildDrawerItem(
                    Icons.local_offer_rounded,
                    'Promotions',
                    showBadge: true,
                  ),
                  _buildDrawerItem(Icons.support_agent_rounded, 'Support'),
                  _buildDrawerItem(Icons.settings_rounded, 'Settings'),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: CustomDivider(),
                  ),
                  _buildDrawerItem(
                    Icons.logout_rounded,
                    'Logout',
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
            _buildAppVersion(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, accentColor],
          stops: const [0.3, 1.0],
        ),
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(25)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_rounded, size: 42, color: accentColor),
            ),
          ),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to PopaRide,',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 5),
              const Row(
                children: [
                  Text(
                    'Alex Johnson',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'alex@example.com',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title, {
    Color? color,
    bool showBadge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title selected'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: primaryColor.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (color ?? primaryColor).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(icon, color: color ?? primaryColor, size: 20),
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color ?? darkText,
                  ),
                ),
                const Spacer(),
                if (showBadge)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'New',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (!showBadge)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppVersion() {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text(
            'PopaRide v1.0.0',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHamburgerMenu() {
    return Positioned(
      top: 50,
      left: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.menu_rounded, color: accentColor, size: 24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSearchBar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: _showTopSearch ? 50 : -200,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.circle, color: primaryColor, size: 12),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _fromController,
                    decoration: const InputDecoration(
                      hintText: 'From',
                      hintStyle: TextStyle(fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey.shade400),
                  onPressed: () => _fromController.clear(),
                  iconSize: 20,
                  splashRadius: 20,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Row(
                children: [
                  Container(width: 1, height: 25, color: Colors.grey.shade300),
                ],
              ),
            ),
            Row(
              children: [
                Icon(Icons.place, color: Colors.redAccent, size: 12),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _toController,
                    decoration: const InputDecoration(
                      hintText: 'To',
                      hintStyle: TextStyle(fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey.shade400),
                  onPressed: () {
                    _toController.clear();
                    setState(() => _showTopSearch = false);
                  },
                  iconSize: 20,
                  splashRadius: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.23,
      minChildSize: 0.18,
      maxChildSize: 0.55,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            physics: const ClampingScrollPhysics(),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Search destination bar
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showTopSearch = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: primaryColor, size: 24),
                      const SizedBox(width: 15),
                      Text(
                        'Where are you going?',
                        style: TextStyle(
                          color: darkText.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Ride type selector
              _buildRideTypeSelector(),
              const SizedBox(height: 25),

              // Find rides button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Looking for available rides...'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Find Rides',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              // Recent searches section
              if (scrollController.hasClients &&
                  scrollController.position.pixels > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Recent Searches',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                    ),
                    _buildRecentSearchItem(
                      'San Francisco',
                      'Los Angeles',
                      '4/10/2025',
                    ),
                    _buildRecentSearchItem('New York', 'Boston', '4/5/2025'),
                    _buildRecentSearchItem('Seattle', 'Portland', '3/28/2025'),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentSearchItem(String from, String to, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      from,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      to,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildRideTypeSelector() {
    // Updated ride types for a car-sharing/ridesharing platform like PopaRide
    final rideTypes = [
      {'name': 'Casual', 'icon': Icons.people_alt_rounded, 'price': 'Budget'},
      {'name': 'Comfort', 'icon': Icons.star_rounded, 'price': 'Regular'},
      {'name': 'Express', 'icon': Icons.flash_on_rounded, 'price': 'Premium'},
    ];

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: rideTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final type = rideTypes[index];
          final bool isSelected = _selectedRideType == type['name'];

          return GestureDetector(
            onTap:
                () =>
                    setState(() => _selectedRideType = type['name'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 110,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : lightGrey,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      type['icon'] as IconData,
                      size: 26,
                      color: isSelected ? Colors.white : primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    type['name'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type['price'] as String,
                    style: TextStyle(
                      color:
                          isSelected
                              ? Colors.white.withOpacity(0.8)
                              : primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(color: Colors.grey.shade200, thickness: 1, height: 20);
  }
}
