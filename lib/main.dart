import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppointmentSystem(),
    );
  }
}

class AppointmentSystem extends StatefulWidget {
  const AppointmentSystem({super.key});

  @override
  AppointmentSystemState createState() => AppointmentSystemState();
}

class AppointmentSystemState extends State<AppointmentSystem> {
  List<AppointmentRequest> pendingRequests = [];
  // Unified list for both calendars.
  List<Appointment> appointments = [];
  // To track rejected requests for the student.
  List<String> rejectedRequests = [];

  // Method to request an appointment from the student side.
  void requestAppointment(String studentName, DateTime startTime) {
    setState(() {
      pendingRequests.add(
        AppointmentRequest(studentName, startTime, false),
      );
    });
  }

  // Method to accept an appointment from the tutor side.
  void acceptAppointment(int index) {
    setState(() {
      var request = pendingRequests[index];
      var acceptedAppointment = Appointment(
        startTime: request.startTime,
        endTime: request.startTime.add(const Duration(minutes: 30)),
        subject: '${request.studentName} - Accepted',
        color: Colors.green,
      );
      // Add to the unified list.
      appointments.add(acceptedAppointment);
      pendingRequests.removeAt(index);
    });
  }

  // Method to reject an appointment from the tutor side.
  void rejectAppointment(int index) {
    setState(() {
      var request = pendingRequests[index];
      // Track rejected request for the student.
      rejectedRequests.add(request.studentName);
      pendingRequests.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment System'),
      ),
      body: Row(
        children: [
          // Student's calendar on the left.
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Student Calendar',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 400,
                  child: SfCalendar(
                    view: CalendarView.month,
                    dataSource: _AppointmentDataSource(appointments),
                    monthViewSettings: const MonthViewSettings(
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showRequestDialog(context),
                  child: const Text('Request Appointment'),
                ),
                // Display rejected requests.
                if (rejectedRequests.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Rejected Requests:',
                      style: TextStyle(fontSize: 16)),
                  ...rejectedRequests
                      .map((name) => Text('Request from $name was rejected.'))
                      .toList(),
                ],
              ],
            ),
          ),
          const VerticalDivider(),
          // Tutor's calendar on the right.
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Tutor Calendar',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 400,
                  child: SfCalendar(
                    view: CalendarView.month,
                    // Same data source.
                    dataSource: _AppointmentDataSource(appointments),
                    monthViewSettings: const MonthViewSettings(
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pending Appointment Requests:',
                  style: TextStyle(fontSize: 16),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: pendingRequests.length,
                    itemBuilder: (context, index) {
                      var request = pendingRequests[index];
                      return ListTile(
                        title: Text('Request from ${request.studentName}'),
                        subtitle: Text('Time: ${request.startTime}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                              onPressed: () => acceptAppointment(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => rejectAppointment(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dialog for requesting an appointment.
  void _showRequestDialog(BuildContext context) {
    final nameController = TextEditingController();
    DateTime selectedTime = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Student Name'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Pick Date & Time'),
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    selectedTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                requestAppointment(nameController.text, selectedTime);
              }
              Navigator.pop(context);
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }
}

// Class to represent an appointment request.
class AppointmentRequest {
  String studentName;
  DateTime startTime;
  bool isAccepted;

  AppointmentRequest(
    this.studentName,
    this.startTime,
    this.isAccepted,
  );
}

// Data source for the Syncfusion calendar.
class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
