import 'package:flutter/material.dart';
import 'package:talk_up/layout/cubit/cubit.dart';
import 'package:talk_up/layout/cubit/states.dart';
import 'package:talk_up/model/status_model.dart';
import 'package:talk_up/modules/status/new_media_status_screen.dart';
import 'package:talk_up/modules/status/new_text_status_screen.dart';
import 'package:talk_up/modules/status/view_status_details_screen.dart';
import 'package:talk_up/shared/components.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    var cubit = AppCubit.get(context);
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: theme.scaffoldBackgroundColor,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  SizedBox(
                    height: 150.0,
                    width: double.infinity,
                    child: Row(
                      children: [
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: StreamBuilder<List<StatusesModel>>(
                            stream: cubit.getAllStatuses(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                // Show a loading indicator while waiting for data
                                return Center(
                                    child: LinearProgressIndicator(color: theme.canvasColor,));
                              }

                              if (snapshot.hasError) {
                                // Handle any errors in the stream
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                // Handle case where no data is returned
                                return Center(
                                    child: Text('No statuses available.'));
                              }

                              // If data is available, display the list of statuses
                              List<StatusesModel> statusesList = snapshot.data!;
                              return ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return buildStatusItem(
                                    context,
                                    theme,
                                    statusesList[index],
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 10.0),
                                itemCount: statusesList.length,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10.0),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        heroTag: 'uniqueTagForThisButton',
                        tooltip: 'New text status',
                        onPressed: () {
                          navigateTo(context, const NewTextStatusScreen());
                        },
                        backgroundColor: theme.canvasColor,
                        child: Icon(
                          Icons.edit,
                          color: theme.primaryColor,
                          size: 30.0,
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      FloatingActionButton(
                        tooltip: 'New media status',
                        onPressed: () async {
                          await AppCubit.get(context)
                              .pickFile(isMediaMessage: false, receiverId: '');
                          navigateTo(
                              context,
                              NewMediaStatusScreen(
                                mediaUrl: AppCubit.get(context).pickedFile!,
                              ));
                        },
                        backgroundColor: theme.canvasColor,
                        child: Icon(
                          Icons.camera_alt,
                          color: theme.primaryColor,
                          size: 35.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildStatusItem(context, ThemeData theme, StatusesModel statusItem) {
    return GestureDetector(
      onTap: () {
        navigateTo(
            context, ViewStatusDetailsScreen(statuesList: statusItem.statuses));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 36.0,
            backgroundColor: theme.canvasColor,
            child: statusItem.image.isNotEmpty
                ? CircleAvatar(
                    radius: 32.0,
                    backgroundColor: theme.secondaryHeaderColor,
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(statusItem.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 50.0,
                    color: theme.secondaryHeaderColor,
                  ),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Text(
            statusItem.name,
            style: TextStyle(
                fontSize: 16.0, color: Theme.of(context).secondaryHeaderColor),
          ),
        ],
      ),
    );
  }
}
