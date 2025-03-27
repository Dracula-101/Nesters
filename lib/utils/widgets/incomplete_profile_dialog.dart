part of "widgets.dart";

void showProfileIncompleteDialog(
  BuildContext context,
  String subtitle, {
  required Function onNavigate,
}) {
  showGeneralDialog(
    context: GoRouter.of(context).routerDelegate.navigatorKey.currentContext!,
    barrierDismissible: true,
    useRootNavigator: false,
    routeSettings: const RouteSettings(name: 'incomplete_profile'),
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black87,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      double iconSize = 100;
      return Material(
        color: Colors.transparent,
        child: Center(
          child: SizedBox(
            width: (MediaQuery.of(context).size.width * 0.75).clamp(250, 290),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: 250 - iconSize / 2,
                  padding: EdgeInsets.only(
                      left: 10, right: 10, top: iconSize / 2 + 10, bottom: 10),
                  margin: EdgeInsets.only(top: iconSize / 2),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Profile Incomplete",
                        style: AppTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: AppTheme.bodyMediumLightVariant,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(buildContext).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(buildContext).pop();
                              onNavigate();
                            },
                            child: const Text('Proceed'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: iconSize,
                  width: iconSize,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.greyShades.shade300,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person_pin,
                    size: 60,
                    color: AppTheme.greyShades.shade300,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: const Offset(0, 0),
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: child,
      );
    },
  );
}
