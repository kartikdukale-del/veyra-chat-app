  import 'package:app/const/custom_color.dart';
  import 'package:app/const/custom_fontweight.dart';
  import 'package:app/const/custom_input.dart';
  import 'package:app/const/custom_string.dart';
  import 'package:app/view/message_screen.dart';
  import 'package:flutter/material.dart';

  
  final List<String> users = [
    "Maya Chen",
    "Noah Williams",
    "Amelia Hart",
    "Sofia Miller",
    "Ethan Brooks",
  ];

  class SearchScreen extends StatefulWidget {
    
    const SearchScreen({super.key});
    @override
    State<SearchScreen> createState() => _SearchScreenState();
  }

  class _SearchScreenState extends State<SearchScreen> {
    late final TextEditingController searchController;
    late final FocusNode searchFocus;
    @override
    void initState(){
      super.initState();
      searchController  = TextEditingController();
      searchFocus = FocusNode();

    }
    @override
    void dispose(){
      searchController.dispose();
      searchFocus.dispose();
      super.dispose();
    }
    Widget build(BuildContext context) {
      final filteredUsers = users.where((user) {
        return user.toLowerCase().contains(searchController.text.toLowerCase());
      }).toList();
      return Scaffold(
        backgroundColor: AppColor.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppString.find, style: TextStyle(fontSize: 25)),

                          SizedBox(height: 5),
                          Text(
                            AppString.search,
                            style: TextStyle(color: AppColor.grey, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Divider(height: 1),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomInput(
                          autofocus: true,
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {});
                          },
                          
                          hintText: "Search usres",
                          prefixicon: Icons.search_rounded,
                          prefixIconColor: AppColor.blue,
                          obscureText: false,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23),
                  child: Text(
                    AppString.suggested,
                    style: TextStyle(fontWeight: AppFontWeight.w500),
                  ),
                ),
                SizedBox(height: 15),
                Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person)),
                            title: Text(
                              filteredUsers[index],
                              style: TextStyle(fontWeight: AppFontWeight.w700),
                            ),

                            subtitle: Text(
                              "Last message here",
                              style: TextStyle(
                                color: AppColor.grey,
                                fontSize: 10,
                              ),
                            ),
                            trailing: TextButton(
                              
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessageScreen(
                                      userName: filteredUsers[index],
                                    ),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: AppColor.buttonBack,
                                foregroundColor: AppColor.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(8)
                                )
                              ),
                              child: Text("Message",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: AppFontWeight.w600,
                              ),),
                            ),
                          ),

                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: AppColor.grey,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
