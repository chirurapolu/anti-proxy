import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OtpManagement extends StatelessWidget {
  const OtpManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Management')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pending_otps')
            .where('consumed', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Database Error: ${snapshot.error}'),
                    const SizedBox(height: 8),
                    const Text(
                        'Ensure Firebase is correctly configured for this project.',
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending OTP requests'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              String userId = doc.id;

              return ListTile(
                title: Text('User ID: $userId'),
                subtitle: Text(
                    'Requested: ${(data['requested_at'] as Timestamp?)?.toDate().toString() ?? 'N/A'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (data['otp'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Text(
                          data['otp'].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.green),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.blue),
                      onPressed: () => _issueOtp(context, userId),
                      tooltip: 'Regenerate OTP',
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _issueOtp(BuildContext context, String userId) async {
    // Generate simple 6-digit OTP
    String otp = (100000 + (DateTime.now().millisecond * 899))
        .toString()
        .padLeft(6, '0')
        .substring(0, 6);

    try {
      await FirebaseFirestore.instance
          .collection('pending_otps')
          .doc(userId)
          .update({
        'otp': otp,
        'issued_at': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('New OTP issued for $userId: $otp')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error updating OTP: $e'),
            backgroundColor: Colors.red));
      }
    }
  }
}
