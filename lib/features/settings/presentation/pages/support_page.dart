import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _englishItems = [
    'Introduction',
    'Opening Balance',
    'Quick Pay',
    'Reports',
    'Settings',
    'Manual Close Loan',
    'How To Delete Customer',
    'Monthly Interest',
    'Owner Login',
  ];

  final List<String> _tamilItems = [
    'அறிமுகம்',
    'முன் இருப்பு',
    'பழைய கணக்கை செயலியில் விரைவில்\nஏற்றுவது எப்படி',
    'விபரம்',
    'அமைப்புகள்',
    'தானாக கடனை முடிக்காதே',
    'வாடிக்கையாளரை நீக்குவது\nஎப்படி',
    'மாதம் வட்டி',
    'பயனர் உள்ளீடு',
    'ஆட்டோ பைனான்ஸ்',
    'பயனர் சம்பளம்',
    'நகை கடன்',
    'விற்பனை(Enterprise)',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildVideoList(List<String> items) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const FaIcon(FontAwesomeIcons.youtube, color: Colors.red, size: 28),
          title: Text(
            items[index],
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          onTap: () {},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 1,
        shadowColor: Colors.black26,
      ),
      body: Column(
        children: [
          // Contact Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.phone_outlined, color: Colors.green, size: 28),
                  title: const Text(
                    '8838070830',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Timing: 8 AM to 9 PM',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),
                const Divider(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.mail_outline, color: Colors.orange, size: 28),
                  title: const Text(
                    'vasooldrive@gmail.com',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: Colors.lightBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.lightBlue,
            tabs: const [
              Tab(text: 'TAMIL'),
              Tab(text: 'ENGLISH'),
            ],
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVideoList(_tamilItems),
                _buildVideoList(_englishItems),
              ],
            ),
          ),
          
          // Device ID Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: const Text(
              'Device ID : ccbfffa62',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
