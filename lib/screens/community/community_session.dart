import 'package:agrinix/config/fonts/font_sizes.dart';
import 'package:agrinix/config/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agrinix/services/messages_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrinix/providers/response_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:cross_file/cross_file.dart';

class CommunitySession extends ConsumerStatefulWidget {
  const CommunitySession({super.key});

  @override
  ConsumerState<CommunitySession> createState() => _CommunitySessionState();
}

class _CommunitySessionState extends ConsumerState<CommunitySession> {
  // CommunityData communityData = CommunityData(); //dummy data for community messages
  final MessagesService messagesService = MessagesService();
  List<dynamic> messages = [];
  List<dynamic> filteredMessages = [];
  bool isLoading = true;
  String errorText = '';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool sendingResponse = false;
  Set<String> likingMessages = {};
  Set<String> likingResponses = {};

  @override
  void initState() {
    super.initState();
    fetchMessages();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
      _filterMessages();
    });
  }

  void _filterMessages() {
    if (_searchQuery.isEmpty) {
      filteredMessages = List.from(messages);
    } else {
      filteredMessages =
          messages.where((msg) {
            final title = (msg['messageTitle'] ?? '').toString().toLowerCase();
            return title.contains(_searchQuery);
          }).toList();
    }
  }

  Future<void> fetchMessages() async {
    setState(() {
      isLoading = true;
      errorText = '';
    });
    try {
      // Use a dummy WidgetRef for now, or refactor to ConsumerStatefulWidget if you want to use ref
      final response = await messagesService.getMessages();
      messages = response.data is List ? response.data : [];
      _filterMessages();
      setState(() {
        isLoading = false;
        errorText = '';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorText = e.toString();
      });
    }
  }

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
          onRefresh: fetchMessages,
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
      controller: _searchController,
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorText.isNotEmpty) {
      return Center(
        child: Text(errorText, style: TextStyle(color: Colors.red)),
      );
    }
    if (filteredMessages.isEmpty) {
      return Center(child: Text('No messages available currently.'));
    } else {
      return ListView.builder(
        shrinkWrap: false,
        itemCount: filteredMessages.length,
        itemBuilder: (context, index) {
          final message = filteredMessages[index];
          final imageUrl = message['messageImage'] ?? "";
          final author = message['author'] ?? {};
          final profileImage = author['profilePicture'] ?? "";
          final authorName = author['name'] ?? "No author";
          final messageId = message['id'] ?? '';
          final isLiking = likingMessages.contains(messageId);

          return InkWell(
            onTap: () {
              _buildBottomSheet(context, message);
            },
            child: Card(
              child: Column(
                children: [
                  if (imageUrl.isNotEmpty)
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
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
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
                          child:
                              profileImage != null && profileImage.isNotEmpty
                                  ? CachedNetworkImage(
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
                                  )
                                  : Icon(Icons.person),
                        ),
                      ),
                      SizedBox(width: FontSizes.spaceSm),
                      Text(
                        authorName,
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
                          label: Text(
                            (message['messageResponses'] is List)
                                ? message['messageResponses'].length.toString()
                                : '0',
                          ),
                          icon: Icon(Icons.forum),
                        ),
                      ],
                    ),
                  ),
                  Divider(thickness: 0.5),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed:
                            isLiking
                                ? null
                                : () async {
                                  setState(() {
                                    likingMessages.add(messageId);
                                  });
                                  try {
                                    await messagesService.likeMessage(
                                      messageId,
                                    );
                                    // if (mounted) {
                                    //   return;
                                    // }
                                    await fetchMessages();
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to like message: $e',
                                          ),
                                          backgroundColor: Colors.red[600],
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        likingMessages.remove(messageId);
                                      });
                                    }
                                  }
                                },
                        label: Text(message['messageLikes']?.toString() ?? "0"),
                        icon:
                            isLiking
                                ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                )
                                : Icon(Icons.thumb_up),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        label: Text(""),
                        icon: Icon(Icons.thumb_down),
                      ),
                      IconButton(
                        onPressed: () async {
                          final shareText =
                              StringBuffer()
                                ..writeln(
                                  'Check out this message on Agrinix Community!',
                                )
                                ..writeln(
                                  'Title: ${message['messageTitle'] ?? ''}',
                                )
                                ..writeln(
                                  'Body: ${message['messageBody'] ?? ''}',
                                );

                          List<XFile> files = [];
                          if (imageUrl.isNotEmpty) {
                            try {
                              // Download the image and save it temporarily
                              final response = await Dio().get(
                                imageUrl,
                                options: Options(
                                  responseType: ResponseType.bytes,
                                ),
                              );

                              if (response.statusCode == 200) {
                                final tempDir = await getTemporaryDirectory();
                                final fileName =
                                    'agrinix_shared_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                final file = File('${tempDir.path}/$fileName');
                                await file.writeAsBytes(response.data);
                                files.add(XFile(file.path));
                              }
                            } catch (e) {
                              // If image download fails, just share text
                              dev.log(
                                'Failed to download image for sharing: $e',
                              );
                            }
                          }

                          await SharePlus.instance.share(
                            ShareParams(
                              text: shareText.toString(),
                              files: files,
                            ),
                          );
                        },
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
    final TextEditingController responseController = TextEditingController();
    final responses = items['messageResponses'] as List<dynamic>? ?? [];
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
                                items['author']['profilePicture'] != null
                                    ? NetworkImage(
                                      items['author']['profilePicture'],
                                    )
                                    : null,
                            child:
                                items['author']["profilePicture"] == null
                                    ? Icon(Icons.person)
                                    : null,
                          ),
                          SizedBox(width: 12),
                          Text(
                            items['author']['name'] ?? 'No author',
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
                      ...responses.map((resp) {
                        final responseId = resp['id']?.toString() ?? '';
                        final isLiking = likingResponses.contains(responseId);
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Icon(Icons.person_outline),
                            title: Text(
                              resp['responseAuthor']['name'] ?? 'Anonymous',
                            ),
                            subtitle: Text(resp['responseBody'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                isLiking
                                    ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                    )
                                    : IconButton(
                                      icon: Icon(Icons.thumb_up, size: 18),
                                      onPressed: () async {
                                        setState(() {
                                          likingResponses.add(responseId);
                                        });
                                        try {
                                          await messagesService.likeResponse(
                                            responseId,
                                          );
                                          // Update the local responseLikes count
                                          setState(() {
                                            resp['responseLikes'] =
                                                (resp['responseLikes'] ?? 0) +
                                                1;
                                          });
                                          await fetchMessages();
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Failed to like response: $e',
                                                ),
                                                backgroundColor:
                                                    Colors.red[600],
                                              ),
                                            );
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              likingResponses.remove(
                                                responseId,
                                              );
                                            });
                                          }
                                        }
                                      },
                                    ),
                                SizedBox(width: 4),
                                Text('${resp['responseLikes'] ?? 0}'),
                                SizedBox(width: 12),
                                Icon(Icons.thumb_down, size: 18),
                                // SizedBox(width: 4),
                                // Text('${resp['responseDislikes'] ?? 0}'),
                              ],
                            ),
                          ),
                        );
                      }),
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
                        onChanged: (value) {
                          ref
                              .read(responseProvider.notifier)
                              .updateResponseBody(value);
                        },
                        controller: responseController,
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
                    sendingResponse
                        ? CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Theme.of(context).colorScheme.primary,
                        )
                        : IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () async {
                            setState(() {
                              sendingResponse = true;
                            });
                            final responseText = responseController.text.trim();
                            if (responseText.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Response cannot be empty.'),
                                  backgroundColor: Colors.red[600],
                                ),
                              );
                              return;
                            }
                            // Update the responseProvider
                            ref
                                .read(responseProvider.notifier)
                                .updateResponseBody(responseText);
                            // Use the messageId from the current message
                            final messageId = items['id'] ?? '';
                            try {
                              setState(() {
                                sendingResponse = true;
                              });

                              await messagesService.sendResponse(
                                ref,
                                messageId,
                              );
                              setState(() {
                                sendingResponse = false;
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Response sent!'),
                                    backgroundColor: Colors.green[600],
                                  ),
                                );
                              }
                              responseController.clear();
                              Navigator.of(context).pop();
                              await fetchMessages();
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to send response: $e',
                                    ),
                                    backgroundColor: Colors.red[600],
                                  ),
                                );
                              }
                            }
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
