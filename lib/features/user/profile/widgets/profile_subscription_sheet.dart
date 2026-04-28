import 'package:flutter/material.dart';

class ProfileSubscriptionSheet extends StatelessWidget {
  const ProfileSubscriptionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'แพ็กเกจสมาชิกพรีเมียม',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _PackageCard(
                    title: 'รายเดือน',
                    price: '฿79.00/เดือน',
                    buttonText: 'ชำระเงินในราคา ฿79.00',
                  ),
                  const SizedBox(height: 16),
                  _PackageCard(
                    title: 'ราย 3 เดือน',
                    price: '฿229.00/3เดือน',
                    subtitles: const ['ประหยัดลง 8 บาท เมื่อเทียบกับรายเดือน'],
                    buttonText: 'ชำระเงินในราคา ฿229.00',
                  ),
                  const SizedBox(height: 16),
                  _PackageCard(
                    title: 'รายปี',
                    price: '฿879.00/ปี',
                    subtitles: const [
                      'ประหยัดลง 69 บาท เมื่อเทียบกับรายเดือน',
                      'ประหยัดลง 37 บาท เมื่อเทียบกับราย3เดือน',
                    ],
                    buttonText: 'ชำระเงินในราคา ฿879.00',
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.title,
    required this.price,
    this.subtitles,
    required this.buttonText,
  });

  final String title;
  final String price;
  final List<String>? subtitles;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (subtitles != null && subtitles!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...subtitles!.map(
              (text) => Text(
                text,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A5DB9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
