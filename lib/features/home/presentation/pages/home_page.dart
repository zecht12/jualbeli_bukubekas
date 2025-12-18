import 'package:audioplayers/audioplayers.dart'; 
import 'package:flutter/material.dart';
import 'package:jualbeli_buku_bekas/features/book/presentation/pages/add_book_page.dart';
import 'package:jualbeli_buku_bekas/features/book/presentation/pages/book_detail_page.dart';
import 'package:jualbeli_buku_bekas/features/cart/presentation/pages/cart_page.dart';
import 'package:jualbeli_buku_bekas/features/chat/presentation/pages/chat_list_page.dart'; 
import 'package:jualbeli_buku_bekas/features/home/logic/home_controller.dart';
import 'package:jualbeli_buku_bekas/features/home/presentation/widget/home_banner.dart';
import 'package:jualbeli_buku_bekas/models/book_model.dart';
import 'package:jualbeli_buku_bekas/shared/widgets/book_card.dart';
import 'package:jualbeli_buku_bekas/shared/widgets/loading_spinner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isLoading = true;
  List<BookModel> _books = [];
  int _unreadCount = 0;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _fetchUnreadCount();
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('sound/notif.wav'));
    } catch (e) {
      debugPrint('Gagal memutar suara: $e');
    }
  }

  Future<void> _fetchUnreadCount() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final count = await Supabase.instance.client
          .from('messages')
          .count(CountOption.exact)
          .eq('is_read', false)
          .neq('sender_id', user.id);
      
      if (mounted) {
        if (!_isFirstLoad && count > _unreadCount) {
          _playNotificationSound();
        }

        setState(() {
          _unreadCount = count;
          _isFirstLoad = false;
        });
      }
    } catch (e) {
      // Abaikan error
    }
  }

  Future<void> _loadBooks() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final data = await _controller.fetchBooks();
      if (!mounted) return;

      setState(() {
        _books = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jual Beli Buku',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListPage()),
              ).then((_) {
                if (mounted) _fetchUnreadCount();
              });
            },
            icon: _unreadCount > 0 
                ? Badge(
                    label: Text(_unreadCount > 99 ? '99+' : '$_unreadCount'),
                    child: const Icon(Icons.chat_bubble_outline),
                  )
                : const Icon(Icons.chat_bubble_outline),
            tooltip: 'Pesan',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Keranjang',
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([_loadBooks(), _fetchUnreadCount()]);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeBanner(),
                    const SizedBox(height: 24),
                    Text(
                      'Terbaru Hari Ini',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              const SliverFillRemaining(
                child: LoadingSpinner(),
              )
            else if (_books.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('Belum ada buku dijual saat ini.')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final book = _books[index];
                      return BookCard(
                        book: book,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailPage(book: book),
                            ),
                          );
                        },
                      );
                    },
                    childCount: _books.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBookPage()),
          ).then((_) {
            if (mounted) _loadBooks(); 
          }); 
        },
        label: const Text('Jual Buku'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}