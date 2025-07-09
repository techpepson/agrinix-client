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
            onTap: () {},
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
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
                  ),
                  SizedBox(height: FontSizes.spaceMd),
                  //message title and body
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              style: Theme.of(context).textTheme.titleLarge,
                              message['messageTitle'] ??
                                  "Message titles usually appear here.",
                            ),
                            SizedBox(width: FontSizes.spaceSm),
                            ...[
                              if (authorId == 23)
                                Icon(
                                  Icons.edit,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            ],
                          ],
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
}
