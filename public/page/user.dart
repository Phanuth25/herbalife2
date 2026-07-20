import 'package:flutter/material.dart';
import 'package:project2/herbalife/public/constants/constants.dart';
import 'package:project2/herbalife/public/provider/info_provider.dart';
import 'package:provider/provider.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InfoProvider>().getAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final infoProvider = context.watch<InfoProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      appBar: AppBar(
        title: const Text(
          "User List",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryGreen,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: infoProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryGreen))
          : RefreshIndicator(
              onRefresh: () => infoProvider.getAllUsers(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWideScreen ? screenWidth * 0.1 : 16.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: kPrimaryGreen,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Registered Users (${infoProvider.users.length})",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: isWideScreen
                                      ? screenWidth * 0.8
                                      : screenWidth - 32,
                                ),
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(
                                    const Color(0xFFE8F5E9),
                                  ),
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        'ID',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Name',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Role',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Status',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: infoProvider.users.map((user) {
                                    // 1. Handle ID Lookup
                                    final dynamic rawId =
                                        user['id'] ?? user['ID'];
                                    final String displayId =
                                        rawId?.toString() ?? 'N/A';
                                    final int userId =
                                        int.tryParse(displayId) ?? 0;

                                    // 2. Map DB role text to Dropdown values "1" and "2"
                                    String dbRole =
                                        user['role']
                                            ?.toString()
                                            .toLowerCase() ??
                                        'user';
                                    String currentValue = (dbRole == 'admin')
                                        ? "1"
                                        : "2";

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(displayId)),
                                        DataCell(Text(user['name'] ?? 'N/A')),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: currentValue,
                                                isDense: true,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                items: const [
                                                  DropdownMenuItem(
                                                    value: "1",
                                                    child: Text("Admin"),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: "2",
                                                    child: Text("Member"),
                                                  ),
                                                ],
                                                onChanged:
                                                    (String? newValue) async {
                                                      if (newValue == null ||
                                                          newValue ==
                                                              currentValue) {
                                                        return;
                                                      }

                                                      if (newValue == "1") {
                                                        await infoProvider
                                                            .updateRoleToAdmin(
                                                              userId,
                                                            );
                                                      } else {
                                                        await infoProvider
                                                            .updateRoleToUser(
                                                              userId,
                                                            );
                                                      }

                                                      if (mounted &&
                                                          infoProvider
                                                                  .message !=
                                                              null) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              infoProvider
                                                                  .message!,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.circle,
                                                size: 8,
                                                color: Colors.green,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "Active",
                                                style: TextStyle(
                                                  color: Colors.green.shade700,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ),
    );
  }
}
