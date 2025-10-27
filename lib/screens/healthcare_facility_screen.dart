//lib/screens/healthcare_facility_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Provider for healthcare facilities
final healthcareFacilitiesProvider =
    FutureProvider.autoDispose<List<HealthcareFacility>>((ref) async {
      final position = await ref.watch(userLocationProvider.future);
      return fetchHealthcareFacilities(position.latitude, position.longitude);
    });

// Provider for user location
final userLocationProvider = FutureProvider.autoDispose<Position>((ref) async {
  return await _determinePosition();
});

class HealthcareFacilityScreen extends ConsumerStatefulWidget {
  const HealthcareFacilityScreen({super.key});

  @override
  ConsumerState<HealthcareFacilityScreen> createState() =>
      _HealthcareFacilityScreenState();
}

class _HealthcareFacilityScreenState
    extends ConsumerState<HealthcareFacilityScreen> {
  late GoogleMapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  final Set<Marker> _markers = {};
  int _selectedTabIndex = 0;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(userLocationProvider);
    final facilitiesAsync = ref.watch(healthcareFacilitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare Facilities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerMapOnUser,
          ),
        ],
      ),
      body: locationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (userPosition) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search hospitals or clinics...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.filter_alt),
                      onPressed: _showFilters,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: _selectedTabIndex,
                  children: [
                    // Map View
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          userPosition.latitude,
                          userPosition.longitude,
                        ),
                        zoom: 14,
                      ),
                      markers: _markers,
                      onMapCreated: (controller) {
                        _mapController = controller;
                        _updateMarkers(facilitiesAsync.value ?? []);
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                    ),
                    // List View
                    facilitiesAsync.when(
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (error, stack) =>
                              Center(child: Text('Error: $error')),
                      data: (facilities) {
                        final filteredFacilities =
                            facilities
                                .where(
                                  (facility) => facility.name
                                      .toLowerCase()
                                      .contains(_searchQuery),
                                )
                                .toList();
                        return ListView.builder(
                          itemCount: filteredFacilities.length,
                          itemBuilder: (context, index) {
                            return _buildFacilityListItem(
                              filteredFacilities[index],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
        ],
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildFacilityListItem(HealthcareFacility facility) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          facility.type == HealthcareFacilityType.hospital
              ? Icons.local_hospital
              : Icons.medical_services,
          size: 36,
        ),
        title: Text(facility.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(facility.address),
            Text('${_calculateDistance(facility.lat, facility.lng)} km away'),
            Wrap(
              spacing: 4,
              children:
                  facility.services
                      .take(3)
                      .map(
                        (service) => Chip(
                          label: Text(service),
                          labelStyle: const TextStyle(fontSize: 10),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.call),
          color: Colors.green,
          onPressed: () => _callFacility(facility.phone),
        ),
        onTap: () => _showFacilityDetails(facility),
      ),
    );
  }

  void _updateMarkers(List<HealthcareFacility> facilities) {
    setState(() {
      _markers.clear();
      for (final facility in facilities) {
        _markers.add(
          Marker(
            markerId: MarkerId(facility.id),
            position: LatLng(facility.lat, facility.lng),
            infoWindow: InfoWindow(
              title: facility.name,
              snippet: facility.address,
            ),
            icon:
                facility.type == HealthcareFacilityType.hospital
                    ? BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    )
                    : BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
          ),
        );
      }
    });
  }

  void _centerMapOnUser() async {
    final position = await ref.read(userLocationProvider.future);
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        14,
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter Facilities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Add your filter options here
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _callFacility(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone app')),
        );
      }
    }
  }

  void _showFacilityDetails(HealthcareFacility facility) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    facility.type == HealthcareFacilityType.hospital
                        ? Icons.local_hospital
                        : Icons.medical_services,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      facility.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(facility.address),
              const SizedBox(height: 8),
              Text('${_calculateDistance(facility.lat, facility.lng)} km away'),
              const Divider(),
              const Text(
                'Services Available:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    facility.services
                        .map((service) => Chip(label: Text(service)))
                        .toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Contact Information:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(facility.phone),
                onTap: () => _callFacility(facility.phone),
              ),
              ListTile(
                leading: const Icon(Icons.directions),
                title: const Text('Get Directions'),
                onTap: () => _openDirections(facility.lat, facility.lng),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _callFacility(facility.phone),
                  child: const Text('Call Now'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openDirections(double lat, double lng) async {
    final position = await ref.read(userLocationProvider.future);
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=${position.latitude},${position.longitude}&destination=$lat,$lng&travelmode=driving',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch maps app')),
        );
      }
    }
  }

  String _calculateDistance(double lat, double lng) {
    final position = ref.read(userLocationProvider).value;
    if (position == null) return 'N/A';

    final distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      lat,
      lng,
    );
    return (distanceInMeters / 1000).toStringAsFixed(1);
  }
}

// Model and helper functions
enum HealthcareFacilityType { hospital, clinic }

class HealthcareFacility {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double lat;
  final double lng;
  final HealthcareFacilityType type;
  final List<String> services;

  HealthcareFacility({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.lat,
    required this.lng,
    required this.type,
    required this.services,
  });
}

Future<Position> _determinePosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied');
  }

  return await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.best,
    ),
  );
}

Future<List<HealthcareFacility>> fetchHealthcareFacilities(
  double lat,
  double lng,
) async {
  // In production, replace with your actual API call
  // This is a mock implementation using OpenStreetMap's Nominatim API
  try {
    final response = await http.get(
      Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=hospital&lat=$lat&lon=$lng&radius=5000',
      ),
      headers: {'User-Agent': 'YourAppName/1.0'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) {
        return HealthcareFacility(
          id: item['osm_id'].toString(),
          name: item['display_name'].split(',').first,
          address: item['display_name'],
          phone: '+1234567890', // Mock phone number
          lat: double.parse(item['lat']),
          lng: double.parse(item['lon']),
          type: HealthcareFacilityType.hospital,
          services: ['Emergency', 'General Medicine'], // Mock services
        );
      }).toList();
    } else {
      throw Exception('Failed to load facilities');
    }
  } catch (e) {
    throw Exception('Error fetching facilities: $e');
  }
}