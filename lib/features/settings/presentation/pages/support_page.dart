import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportItem {
  final String title;
  final String? url;
  
  const SupportItem({required this.title, this.url});
}

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<SupportItem> _englishItems = [
    const SupportItem(title: 'Introduction', url: 'https://youtu.be/cxdfuZ65lwU?si=PBVIFevGhBVlbSEK'),
    const SupportItem(title: 'Opening Balance', url: "https://youtu.be/rO7HjjG6qno?si=bZgpdpO8ec2yoIow"),
    const SupportItem(title: 'Quick Pay', url: "https://youtu.be/XzhapzfxCDU?si=M24T6ywy_njJF3H0"),
    const SupportItem(title: 'Reports', url: "https://youtu.be/QaRf-V14kDA?si=KZvCg1E6PB_EDSkc"),
    const SupportItem(title: 'Settings', url: "https://youtu.be/Cnl6Gc221DU?si=pGDL0upToj26_MHQ"),
    const SupportItem(title: 'Manual Close Loan', url: "https://youtu.be/NRNMeHPTPZs?si=GkOffNQ4jPtoV2jR"),
    const SupportItem(title: 'How To Delete Customer', url: "https://youtu.be/R186ojaUhSY?si=_vE6P6z53URREvl6"),
    const SupportItem(title: 'Monthly Interest', url: "https://youtu.be/CdtKUf3TM4g?si=p4O6W7xrpH36b3eb"),
    const SupportItem(title: 'Owner Login', url: "https://youtu.be/EjqKN6QmOA4?si=Dulf_WTVYATnhuln"),
  ];

  final List<SupportItem> _tamilItems = [
    const SupportItem(title: 'அறிமுகம்', url: 'https://youtu.be/jQeRdhTYVRY?si=pY6nZcuzP3aFcFOe'),
    const SupportItem(title: 'முன் இருப்பு',  url: "https://youtu.be/Ms9s9BwGTAE?si=fJVcunfixg6wwZ36"),
    const SupportItem(title: 'பழைய கணக்கை செயலியில் விரைவில்\nஏற்றுவது எப்படி', url: "https://youtu.be/akjt0x6n4Hg?si=XsfsiR1xDEa4o7sX"),
    const SupportItem(title: 'விபரம்', url: "https://youtu.be/tWmkLHmS3Sk?si=-_6f_1MQsEK4s2qx"),
    const SupportItem(title: 'அமைப்புகள்', url: "https://youtu.be/oHQhsPi6ndg?si=M1Qct75YCBFE1qMO"),
    const SupportItem(title: 'தானாக கடனை முடிக்காதே', url: "https://youtu.be/9qwqCkvKR9w?si=nEHT6ej2-9SsfFuY"),
    const SupportItem(title: 'வாடிக்கையாளரை நீக்குவது\nஎப்படி', url: "https://youtu.be/FAPbd9lMN-w?si=MYFm5eMPzwAX7pe2"),
    const SupportItem(title: 'மாதம் வட்டி', url: "https://youtu.be/vCw4vNKJ3WI?si=6R_p-B7IK2JjWbvJ"),
    const SupportItem(title: 'பயனர் உள்ளீடு', url: "https://youtu.be/2--JU9Dz0Lk?si=eCooo37c6NwjXR1q"),
    const SupportItem(title: 'ஆட்டோ பைனான்ஸ்', url: "https://youtu.be/1C0A7BP6nq0?si=-I9mClKlvDAxnIZR"),
    const SupportItem(title: 'பயனர் சம்பளம்', url: "https://youtu.be/sBk30cgJw9o?si=3lgZBXeHAyye2xTk"),
    const SupportItem(title: 'நகை கடன்', url: "https://youtu.be/B7CV34iEIio?si=iiIPS6_dxTfRJ7Wk"),
    const SupportItem(title: 'விற்பனை(Enterprise)', url: "https://youtu.be/A_NrNNV9YWs?si=Y_Khfn5AwmBEcdIi"),
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

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open video')),
        );
      }
    }
  }

  Widget _buildVideoList(List<SupportItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const FaIcon(FontAwesomeIcons.youtube, color: Colors.red, size: 28),
          title: Text(
            item.title,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          onTap: () => _launchUrl(item.url),
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
