import 'package:flutter/material.dart';
import 'package:b_connect_task/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomMessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final bool isLocation;
  final double? latitude;
  final double? longitude;
  final DateTime? time;

  const CustomMessageBubble({
    Key? key,
    required this.text,
    required this.isMe,
    this.isLocation = false,
    this.latitude,
    this.longitude,
    this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isMe ? AppColors.main : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(15),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLocation)
              GestureDetector(
                onTap: () => _launchMaps(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الموقع الحالي',
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'اضغط هنا لفتح الخريطة',
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.black54,
                        fontFamily: 'Cairo',
                        fontSize: 12,
                      ),
                    ),
                    const Icon(Icons.location_on, size: 30),
                  ],
                ),
              )
            else
              Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontFamily: 'Cairo',
                ),
              ),
            const SizedBox(height: 5),
            if (time != null)
              Text(
                '${time!.hour}:${time!.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black54,
                  fontFamily: 'Cairo',
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchMaps() async {
    if (latitude == null || longitude == null) return;
    
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}