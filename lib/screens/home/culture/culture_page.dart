import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:malibots_challenge_eni/providers/favoris_store.dart';
import 'package:provider/provider.dart';
import 'conte_detail_page.dart';
import 'proverbe_detail_page.dart';

class CulturePage extends StatefulWidget {
  const CulturePage({super.key});

  @override
  State<CulturePage> createState() => _CulturePageState();
}

class _CulturePageState extends State<CulturePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> contes = [
    {
      'titre': 'Sanoun Djai',
      'resume':
          'Une princesse qui, le jour de son mariage, perd ses deux parents et devient esclave',
      'origine': 'Conte malien',
      'contenu':
          'Sanoun Djai était une princesse promise à un grand avenir, mais le destin en décida autrement...',
    },
    {
      'titre': 'Abi l’orpheline',
      'resume':
          'Abi une orpheline qui perdit ses parents étant jeune et se retrouve maltraitée par sa marâtre',
      'origine': 'Conte africain',
      'contenu':
          'Abi était une jeune fille courageuse qui, malgré les épreuves, sut faire preuve de bonté...',
    },
    {
      'titre': 'Souroukouba ni zoganinba',
      'resume':
          'Souroukou est bête et pense que la force résout tout alors que zoganinba est rusé et malin',
      'origine': 'Conte bambara',
      'contenu':
          'Ce conte illustre la supériorité de la ruse sur la force brute...',
    },
  ];

  final List<Map<String, String>> proverbes = [
    {'texte': 'Ahh les dogons sont foutus', 'origine': 'Proverbe sonrhai'},
    {
      'texte': 'On ne mord pas la main qui nous nourrit',
      'origine': 'Proverbe bambara',
    },
    {
      'texte': 'Ni chou ye a dogo a koli baga la a nogolen beta lagara',
      'origine': 'Proverbe bambara',
    },
  ];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Culture',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications, color: Colors.brown),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.brown,
          labelColor: Colors.brown,
          unselectedLabelColor: Colors.black54,
          tabs: const [
            Tab(text: 'Contes'),
            Tab(text: 'Proverbes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildContesTab(), _buildProverbesTab()],
      ),
    );
  }

  // ---------- Contes ----------
  Widget _buildContesTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: contes.length,
            itemBuilder: (context, index) {
              return ConteCard(conte: contes[index]);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {},
            child: const Text('Ajouter un conte', style: AppTextStyles.button),
          ),
        ),
      ],
    );
  }

  // ---------- Proverbes ----------
  Widget _buildProverbesTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: proverbes.length,
            itemBuilder: (context, index) {
              return ProverbeCard(proverbe: proverbes[index]);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {},
            child: const Text(
              'Ajouter un proverbe',
              style: AppTextStyles.button,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------- Widget Carte Conte ----------
class ConteCard extends StatefulWidget {
  final Map<String, String> conte;
  const ConteCard({super.key, required this.conte});

  @override
  State<ConteCard> createState() => _ConteCardState();
}

class _ConteCardState extends State<ConteCard> {
  @override
  Widget build(BuildContext context) {
    final store = context.watch<FavoritesStore>();
    final id = store.conteIdFrom(widget.conte);          
    final isFav = store.isConteFavorite(id);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConteDetailPage(conte: widget.conte),
          ),
        );
      },
      child: Card(
        color: AppColors.primary,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.conte['titre']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.conte['resume']!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      final wasFav = isFav;
                      context.read<FavoritesStore>().toggleConte(widget.conte);

                      final text = wasFav
                          ? 'Conte retiré des favoris'
                          : 'Conte ajouté aux favoris';
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(content: Text(text)));
                    },
                  ),
                  const Text('Lire', style: TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Widget Carte Proverbe ----------
class ProverbeCard extends StatefulWidget {
  final Map<String, String> proverbe;
  const ProverbeCard({super.key, required this.proverbe});

  @override
  State<ProverbeCard> createState() => _ProverbeCardState();
}

class _ProverbeCardState extends State<ProverbeCard> {

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FavoritesStore>();
    final id = store.proverbeIdFrom(widget.proverbe);     
    final isFav = store.isProverbeFavorite(id);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProverbeDetailPage(proverbe: widget.proverbe),
          ),
        );
      },
      child: Card(
        color: AppColors.primary,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.proverbe['texte']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.proverbe['origine']!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      final wasFav = isFav;
                      context.read<FavoritesStore>().toggleProverbe(widget.proverbe);

                      final text = wasFav
                          ? 'Proverbe retiré des favoris'
                          : 'Proverbe ajouté aux favoris';
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(content: Text(text)));
                      
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}