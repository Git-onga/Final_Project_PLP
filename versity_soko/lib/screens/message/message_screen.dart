import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _ActivityHubScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [
    Message(
      text: 'Hello! I\'m interested in the Nike Air shoes. Are they still available?',
      isMe: false,
      time: '10:30 AM',
      senderName: 'Sarah T.',
    ),
    Message(
      text: 'Yes, they are available! They\'re in great condition and barely worn.',
      isMe: true,
      time: '10:32 AM',
    ),
    Message(
      text: 'That\'s great! What size are they and could you send more photos?',
      isMe: false,
      time: '10:33 AM',
      senderName: 'Sarah T.',
    ),
    Message(
      text: 'They\'re size 42. Here are some more photos:',
      isMe: true,
      time: '10:35 AM',
    ),
    Message(
      text: 'Perfect! Could we meet on campus tomorrow?',
      isMe: false,
      time: '10:36 AM',
      senderName: 'Sarah T.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.grey[700],
          size: 20,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Row(
        children: [
          // Profile Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/100/100?random=1'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sarah T.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Online',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.phone,
            color: Colors.grey[700],
            size: 20,
          ),
          onPressed: () {
            // Handle call
          },
        ),
        IconButton(
          icon: Icon(
            Icons.videocam,
            color: Colors.grey[700],
            size: 20,
          ),
          onPressed: () {
            // Handle video call
          },
        ),
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: Colors.grey[700],
            size: 20,
          ),
          onPressed: () {
            // Handle more options
          },
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      reverse: false,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            // Sender Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage('https://picsum.photos/100/100?random=2'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!message.isMe)
                  Text(
                    message.senderName!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isMe ? Colors.blue : Colors.grey[100],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: message.isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.time,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          if (message.isMe) ...[
            const SizedBox(width: 8),
            // My Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage('https://picsum.photos/100/100?random=3'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Attachment Button
          IconButton(
            icon: Icon(
              Icons.attach_file,
              color: Colors.grey[600],
              size: 20,
            ),
            onPressed: () {
              // Handle attachment
            },
          ),
          // Emoji Button
          IconButton(
            icon: Icon(
              Icons.emoji_emotions_outlined,
              color: Colors.grey[600],
              size: 20,
            ),
            onPressed: () {
              // Handle emoji
            },
          ),
          // Message Input
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.grey[300]!,
                ),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                  ),
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
            ),
          ),
          // Send Button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 18,
              ),
            ),
            onPressed: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add(Message(
          text: text,
          isMe: true,
          time: 'Now',
        ));
        _messageController.clear();
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class Message {
  final String text;
  final bool isMe;
  final String time;
  final String? senderName;

  Message({
    required this.text,
    required this.isMe,
    required this.time,
    this.senderName,
  });
}

// class ActivityHubScreen extends StatefulWidget {
//   const ActivityHubScreen({super.key});

//   @override
//   State<ActivityHubScreen> createState() => _ActivityHubScreenState();
// }

class _ActivityHubScreenState extends State<MessageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Activity Hub'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        automaticallyImplyLeading: false, // 🔥 Hides the default back button
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Orders'),
            Tab(text: 'Payments'),
            Tab(text: 'Messages'),
            Tab(text: 'Utilities'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OrdersTab(),
          PaymentsTab(),
          MessagesTab(),
          UtilitiesTab(),
        ],

      ),
      bottomNavigationBar: CustomBottomNavBar(
				currentIndex: 0,
				onTap: (index) {
				switch (index) {
					case 0:
					Navigator.pushNamed(context, '/home');
					case 1:
					Navigator.pushNamed(context, '/shops');
					break;
					case 2:
					Navigator.pushNamed(context, '/create');
					break;
					case 3:
					Navigator.pushNamed(context, '/community');
					break;
					case 4:
					Navigator.pushNamed(context, '/message');
				}
				},
			),
    );
  }
}

// ORDERS TAB
class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});
  

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Orders Section
                _buildSectionHeader(
                  title: 'Current Orders',
                  icon: Icons.pending_actions,
                ),
                const SizedBox(height: 12),
                _buildOrderCard(
                  orderId: '#ORD-7842',
                  status: 'In Transit',
                  items: '3 items',
                  date: 'Today, 10:30 AM',
                  amount: '\$124.99',
                  statusColor: Colors.orange,
                  showTracking: true,
                ),
                const SizedBox(height: 12),
                _buildOrderCard(
                  orderId: '#ORD-7839',
                  status: 'Processing',
                  items: '1 item',
                  date: 'Yesterday, 3:45 PM',
                  amount: '\$49.99',
                  statusColor: Colors.blue,
                  showTracking: false,
                ),
              ],
            ),
          ),
        ),
        
        // Order History Section
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _buildSectionHeader(
              title: 'Order History',
              icon: Icons.history,
            ),
          ),
        ),
        
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final orders = [
                  {
                    'id': '#ORD-7831',
                    'status': 'Delivered',
                    'items': '2 items',
                    'date': 'Oct 12, 2024',
                    'amount': '\$89.99',
                    'statusColor': Colors.green,
                  },
                  {
                    'id': '#ORD-7825',
                    'status': 'Delivered',
                    'items': '1 item',
                    'date': 'Oct 8, 2024',
                    'amount': '\$34.99',
                    'statusColor': Colors.green,
                  },
                  {
                    'id': '#ORD-7818',
                    'status': 'Cancelled',
                    'items': '4 items',
                    'date': 'Oct 3, 2024',
                    'amount': '\$156.50',
                    'statusColor': Colors.red,
                  },
                ];
                
                if (index >= orders.length) return null;
                final order = orders[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCompactOrderCard(
                    orderId: order['id']='MJW-2121',
                    status: order['status']='Delivered',
                    items: order['items']='2 items',
                    date: order['date']='Oct 12, 2024',
                    amount: order['amount']='KES 2100.25',
                    statusColor: order['statusColor'] as Color,
                  ),
                );
              },
            ),
          ),
        ),
        
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard({
    required String orderId,
    required String status,
    required String items,
    required String date,
    required String amount,
    required Color statusColor,
    required bool showTracking,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            items,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              if (showTracking)
                ElevatedButton(
                  onPressed: () {
                    // Track order action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Track Order'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactOrderCard({
    required String orderId,
    required String status,
    required String items,
    required String date,
    required String amount,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$items • $date',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.green,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// PAYMENTS TAB
class PaymentsTab extends StatelessWidget {
  const PaymentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                // Payment Methods
                _buildPaymentMethodsSection(),
                const SizedBox(height: 24),
                
                // Recent Transactions
                _buildTransactionsSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.credit_card, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Payment Methods',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Saved Cards
          _buildPaymentMethodItem(
            icon: Icons.credit_card,
            title: 'Visa ending in 4242',
            subtitle: 'Expires 12/25',
            isDefault: true,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodItem(
            icon: Icons.credit_card,
            title: 'Mastercard ending in 8888',
            subtitle: 'Expires 08/26',
            isDefault: false,
          ),
          const SizedBox(height: 16),
          
          // Add New Method Button
          OutlinedButton.icon(
            onPressed: () {
              // Add payment method
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Payment Method'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDefault,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDefault ? Colors.blue : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Default',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection() {
    final transactions = [
      {
        'title': 'Order #ORD-7842',
        'date': 'Today, 10:30 AM',
        'amount': '-\$124.99',
        'type': 'debit',
        'icon': Icons.shopping_bag,
      },
      {
        'title': 'Refund #REF-4521',
        'date': 'Oct 15, 2024',
        'amount': '+\$49.99',
        'type': 'credit',
        'icon': Icons.assignment_return,
      },
      {
        'title': 'Order #ORD-7831',
        'date': 'Oct 12, 2024',
        'amount': '-\$89.99',
        'type': 'debit',
        'icon': Icons.shopping_bag,
      },
      {
        'title': 'Wallet Top-up',
        'date': 'Oct 10, 2024',
        'amount': '+\$100.00',
        'type': 'credit',
        'icon': Icons.account_balance_wallet,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long, size: 20, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...transactions.map((transaction) => Column(
            children: [
              _buildTransactionItem(
                icon: transaction['icon'] as IconData,
                title: transaction['title'] as String,
                date: transaction['date'] as String,
                amount: transaction['amount'] as String,
                isCredit: transaction['type'] == 'credit',
              ),
              if (transaction != transactions.last)
                const SizedBox(height: 12),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String date,
    required String amount,
    required bool isCredit,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCredit ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isCredit ? Colors.green : Colors.blue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isCredit ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}

// MESSAGES TAB
class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                // Unread Messages
                _buildMessageCard(
                  name: 'Tech Store Support',
                  message: 'Your order #ORD-7842 has been shipped! Tracking number: TRK784215',
                  time: '10:45 AM',
                  unread: true,
                  isSupport: true,
                ),
                const SizedBox(height: 12),
                
                _buildMessageCard(
                  name: 'Sarah Johnson',
                  message: 'Thanks for your purchase! Let me know if you have any questions about the product.',
                  time: 'Yesterday',
                  unread: true,
                  isSupport: false,
                ),
              ],
            ),
          ),
        ),
        
        // Recent Conversations
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _buildSectionHeader(
              title: 'Recent Conversations',
              icon: Icons.chat_bubble_outline,
            ),
          ),
        ),
        
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final conversations = [
                  {
                    'name': 'Design Studio',
                    'message': 'We received your custom design request',
                    'time': 'Oct 15',
                    'unread': false,
                  },
                  {
                    'name': 'Mike\'s Electronics',
                    'message': 'Your warranty has been registered',
                    'time': 'Oct 14',
                    'unread': false,
                  },
                  {
                    'name': 'Book Store',
                    'message': 'Your pre-order is ready for pickup',
                    'time': 'Oct 12',
                    'unread': false,
                  },
                ];
                
                if (index >= conversations.length) return null;
                final conv = conversations[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildMessageCard(
                    name: conv['name'] as String,
                    message: conv['message'] as String,
                    time: conv['time'] as String,
                    unread: conv['unread'] as bool,
                    isSupport: false,
                  ),
                );
              },
            ),
          ),
        ),
        
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard({
    required String name,
    required String message,
    required String time,
    required bool unread,
    required bool isSupport,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSupport ? Colors.blue.withOpacity(0.1) : Colors.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSupport ? Icons.support_agent : Icons.person,
              color: isSupport ? Colors.blue : Colors.purple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: unread ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: unread ? FontWeight.w500 : FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (unread)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

// UTILITIES TAB
class UtilitiesTab extends StatelessWidget {
  const UtilitiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                // Quick Actions Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildUtilityCard(
                      icon: Icons.request_quote,
                      title: 'Refund Requests',
                      color: Colors.orange,
                      onTap: () {
                        // Handle refund request
                      },
                    ),
                    _buildUtilityCard(
                      icon: Icons.receipt,
                      title: 'Invoice Downloads',
                      color: Colors.blue,
                      onTap: () {
                        // Handle invoice download
                      },
                    ),
                    _buildUtilityCard(
                      icon: Icons.help_center,
                      title: 'Help Center',
                      color: Colors.green,
                      onTap: () {
                        // Handle help center
                      },
                    ),
                    _buildUtilityCard(
                      icon: Icons.settings,
                      title: 'Account Settings',
                      color: Colors.purple,
                      onTap: () {
                        // Handle settings
                      },
                    ),
                    _buildUtilityCard(
                      icon: Icons.security,
                      title: 'Privacy & Security',
                      color: Colors.red,
                      onTap: () {
                        // Handle privacy
                      },
                    ),
                    _buildUtilityCard(
                      icon: Icons.contact_support,
                      title: 'Contact Support',
                      color: Colors.teal,
                      onTap: () {
                        // Handle contact support
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Support Section
                _buildSupportSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUtilityCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.help_outline, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Need Help?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Our support team is here to help you with any questions or issues you might have.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Contact support
                  },
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('Live Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Call support
                  },
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Call Us'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}