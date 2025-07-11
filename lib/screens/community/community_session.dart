import 'package:agrinix/config/fonts/font_sizes.dart';
import 'package:agrinix/config/theme/app_theme.dart';
import 'package:agrinix/data/community_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommunitySession extends StatefulWidget {
  const CommunitySession({super.key});

  @override
  State<CommunitySession> createState() => _CommunitySessionState();
}

class _CommunitySessionState extends State<CommunitySession> {
  CommunityData communityData =
      CommunityData(); //dummy data for community messages

  bool isLoading = false;
  bool isSuccess = false;
  bool isError = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/community/create-message');
        },
        child: Icon(Icons.chat_bubble_outline),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            return await Future.delayed(Duration(seconds: 10));
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: FontSizes.spaceMd,
              vertical: FontSizes.spaceSm,
            ),
            child: Column(
              children: [
                _buildSearchBar(),
                SizedBox(height: FontSizes.spaceMd),
                Expanded(child: _buildMessageList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search Community",
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(
            width: 1.0,
            color: Colors.grey,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    if (communityData.messages.isEmpty) {
      return Center(child: Text('No messages available currently.'));
    } else {
      return ListView.builder(
        shrinkWrap: false,
        itemCount: communityData.messages.length,
        itemBuilder: (context, index) {
          final message = communityData.messages[index];
          final imageUrl = message['messageImage'] ?? "";
          final profileImage = message['profileImage'] ?? "";
          final authorId = message['authorId'];

          return InkWell(
            onTap: () {
              _buildBottomSheet(context, message);
            },
            child: Card(
              child: Column(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              color: Colors.grey[200],
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                child: Image.asset(
                                  'assets/images/image_bg.jpg',
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                  SizedBox(height: FontSizes.spaceMd),
                  Row(
                    children: [
                      CircleAvatar(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: profileImage,
                            placeholder: (context, url) {
                              return CircularProgressIndicator(
                                strokeWidth: 1.5,
                              );
                            },
                            errorWidget: (context, url, error) {
                              return Icon(Icons.person);
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: FontSizes.spaceSm),
                      Text(
                        message['messageAuthor'] ?? "No author",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(width: FontSizes.spaceSm),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: appTheme.primaryColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      SizedBox(width: FontSizes.spaceSm),
                      Text('Ghana'),
                    ],
                  ),
                  SizedBox(height: FontSizes.spaceMd),
                  //message title and body
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            message['messageTitle'] ??
                                "Message titles usually appear here.",
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing:
                              authorId == 23
                                  ? PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        // TODO: Implement edit functionality
                                      } else if (value == 'delete') {
                                        // TODO: Implement delete functionality
                                      } else if (value == 'share') {
                                        // TODO: Implement share functionality
                                      }
                                    },
                                    itemBuilder:
                                        (context) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.edit,
                                                  color: Colors.black54,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  color: Colors.redAccent,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Delete'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'share',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.share,
                                                  color: Colors.black54,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Share'),
                                              ],
                                            ),
                                          ),
                                        ],
                                  )
                                  : null,
                        ),
                        Text(
                          style: Theme.of(context).textTheme.bodyLarge,
                          message['messageBody'] ??
                              "Message bodies appear here.",
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        SizedBox.shrink(),
                        TextButton.icon(
                          onPressed: () {},
                          label: Text(message['messageResponses'].toString()),
                          icon: Icon(Icons.forum),
                        ),
                      ],
                    ),
                  ),
                  Divider(thickness: 0.5),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        label: Text(message['messageLikes']?.toString() ?? "0"),
                        icon: Icon(Icons.thumb_up),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        label: Text(
                          message['messageDislikes']?.toString() ?? "0",
                        ),
                        icon: Icon(Icons.thumb_down),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.share,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Future _buildBottomSheet(
    BuildContext context,
    Map<String, dynamic> items,
  ) async {
    final TextEditingController _responseController = TextEditingController();
    final responses = items['responses'] as List<dynamic>? ?? [];
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                items['profileImage'] != null
                                    ? NetworkImage(items['profileImage'])
                                    : null,
                            child:
                                items['profileImage'] == null
                                    ? Icon(Icons.person)
                                    : null,
                          ),
                          SizedBox(width: 12),
                          Text(
                            items['messageAuthor'] ?? 'No author',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      if (items['messageTitle'] != null)
                        Text(
                          items['messageTitle'],
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      SizedBox(height: 8),
                      if (items['messageBody'] != null)
                        Text(
                          items['messageBody'],
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      SizedBox(height: 16),
                      if (items['messageImage'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            items['messageImage'],
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(height: 24),
                      Text(
                        'Responses',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      if (responses.isEmpty) Text('No responses yet.'),
                      ...responses.map(
                        (resp) => Card(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Icon(Icons.person_outline),
                            title: Text(resp['responseAuthor'] ?? 'Anonymous'),
                            subtitle: Text(resp['responseBody'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.thumb_up, size: 18),
                                SizedBox(width: 4),
                                Text('${resp['responseLikes'] ?? 0}'),
                                SizedBox(width: 12),
                                Icon(Icons.thumb_down, size: 18),
                                SizedBox(width: 4),
                                Text('${resp['responseDislikes'] ?? 0}'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _responseController,
                        decoration: InputDecoration(
                          hintText: 'Type your response...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        minLines: 1,
                        maxLines: 3,
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        // For demo: just clear the field. You can add logic to update the UI if needed.
                        FocusScope.of(context).unfocus();
                        _responseController.clear();
                        // Optionally, show a snackbar or feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Response sent! (Demo only)')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
