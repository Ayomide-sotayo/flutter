import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage> {
  bool showUpcoming = true;

  @override
  Widget build(BuildContext context) {
    final trips = showUpcoming ? upcomingRides : pastRides;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Rides',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text(
                      'Upcoming',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    selected: showUpcoming,
                    selectedColor: Colors.blue[800],
                    labelStyle: TextStyle(
                      color: showUpcoming ? Colors.white : Colors.black87,
                    ),
                    backgroundColor: Colors.grey[200],
                    onSelected: (_) {
                      setState(() => showUpcoming = true);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: Text(
                      'Past Rides',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    selected: !showUpcoming,
                    selectedColor: Colors.blue[800],
                    labelStyle: TextStyle(
                      color: !showUpcoming ? Colors.white : Colors.black87,
                    ),
                    backgroundColor: Colors.grey[200],
                    onSelected: (_) {
                      setState(() => showUpcoming = false);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: trips.isEmpty
                ? Center(
                    child: Text(
                      'No ${showUpcoming ? 'upcoming' : 'past'} rides',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: trips.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final ride = trips[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.07),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.blueAccent, Colors.lightBlue],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.local_taxi,
                                      color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ride['from']!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          )),
                                      const SizedBox(height: 4),
                                      Text(ride['to']!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          )),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              size: 14, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(ride['date']!,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              )),
                                          const Spacer(),
                                          Text('₦${ride['price']}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue[800],
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

final List<Map<String, String>> upcomingRides = [
  {
    'from': 'Lekki Phase 1',
    'to': 'Yaba Tech Gate',
    'date': 'Apr 14, 2025 · 10:00 AM',
    'price': '2,500',
  },
];

final List<Map<String, String>> pastRides = [
  {
    'from': 'Shoprite Ikeja',
    'to': 'Anthony Bus Stop',
    'date': 'Apr 9, 2025 · 9:30 AM',
    'price': '3,200',
  },
  {
    'from': 'Circle Mall',
    'to': 'CMS Lagos Island',
    'date': 'Apr 2, 2025 · 8:00 AM',
    'price': '3,000',
  },
];
