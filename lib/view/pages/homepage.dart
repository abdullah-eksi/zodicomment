import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zodicomment/viewmodel/home_viewmodel.dart';
import 'package:zodicomment/view/components/chat_list.dart';
import 'package:zodicomment/view/components/chat_input.dart';
import 'package:zodicomment/view/components/maskot_header.dart';
import 'package:zodicomment/view/components/sidebar_menu.dart';
import 'package:zodicomment/view/components/thinking_maskot.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(context, listen: false).initializeChat();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, viewModel),
      drawer: _buildDrawer(context, viewModel),
      body: _buildBody(context, viewModel),
    );
  }

  /// AppBar bileşeni
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    HomeViewModel viewModel,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          tooltip: 'Sohbetler',
          onPressed: viewModel.isLoading
              ? null
              : () async {
                  // Sohbet geçmişini yükle
                  await viewModel.initializeChat();
                  if (mounted) Scaffold.of(context).openDrawer();
                },
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Çıkış Yap',
          onPressed: viewModel.isLoading
              ? null
              : () => viewModel.logout(context),
        ),
      ],
    );
  }

  /// Drawer (yan menü) bileşeni
  Widget _buildDrawer(BuildContext context, HomeViewModel viewModel) {
    return Drawer(
      child: SafeArea(
        child: SidebarMenu(
          chatHistory: viewModel.chatHistory,
          onNewChat: () => viewModel.newChat(context),
          onSelectChat: (chat) => viewModel.selectHistory(context, chat),
          onClose: () => Navigator.of(context).pop(),
          onProfileTap: () => viewModel.openProfile(context),
        ),
      ),
    );
  }

  /// Sayfa içeriği
  Widget _buildBody(BuildContext context, HomeViewModel viewModel) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 32),
              const MaskotHeader(
                imagePath: 'assets/images/maskot.png',
                title: 'ZodiComment',
                subtitle: 'Mistik sohbet asistanınız',
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ChatList(
                    messages: viewModel.messages,
                    guidanceMessage: viewModel.getGuidanceMessage(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: ChatInput(
                  controller: viewModel.messageController,
                  onSend: () => viewModel.sendMessage(context),
                  noActiveChat: viewModel.currentChatId == null,
                  isDisabled:
                      viewModel.waitingForAI || viewModel.currentChatId == null,
                ),
              ),
            ],
          ),
          // AI düşünüyor animasyonu
          if (viewModel.waitingForAI)
            const Positioned(
              bottom: 70,
              left: 0,
              right: 0,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ThinkingMaskot(),
                ),
              ),
            ),
          // Genel yükleme göstergesi
          if (viewModel.isLoading && !viewModel.waitingForAI)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }
}
