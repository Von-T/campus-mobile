import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/hooks/map_query.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/utils/webview.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewContainer extends StatefulHookWidget {
  const WebViewContainer({
    Key? key,
    required this.titleText,
    required this.initialUrl,
    required this.cardId,
    required this.requireAuth,
    this.overFlowMenu,
    this.actionButtons,
    this.hideMenu,
  }) : super(key: key);

  /// required parameters
  final String? titleText;
  final String? initialUrl;
  final String cardId;
  final bool? requireAuth;

  /// optional parameters
  final Map<String, Function>? overFlowMenu;
  final bool? hideMenu;
  final List<Widget>? actionButtons;

  @override
  _WebViewContainerState createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer>
    with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;
  late UserDataProvider _userDataProvider;
  WebViewController? _webViewController;
  double _contentHeight = cardContentMinHeight;
  bool? active;
  Function? hide;
  String? webCardUrl;

  @override
  void initState() {
    super.initState();
    hide = () => Provider.of<CardsDataProvider>(context, listen: false)
        .toggleCard(widget.cardId);
  }

  @override
  Widget build(BuildContext context) {
    final mapHooks = useFetchMapModel();
    super.build(context);
    active = Provider.of<CardsDataProvider>(context).cardStates![widget.cardId];

    // check if this webCard needs an auth token
    if (widget.requireAuth!) {
      _userDataProvider = Provider.of<UserDataProvider>(context);
      webCardUrl = widget.initialUrl! +
          "?expiration=${_userDataProvider.authenticationModel!.expiration}#${_userDataProvider.authenticationModel!.accessToken}";
    } else {
      webCardUrl = widget.initialUrl;
    }

    checkWebURL();

    if (active != null && active!) {
      final card = Card(
        margin: EdgeInsets.only(
            top: 0.0, right: 0.0, bottom: cardMargin * 1.5, left: 0.0),
        semanticContainer: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.only(
                  top: 0.0, right: 6.0, bottom: 0.0, left: 12.0),
              visualDensity: VisualDensity(horizontal: 0, vertical: 0),
              title: Text(
                widget.titleText!,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18.0,
                ),
              ),
              trailing: buildMenu()!,
            ),
            buildBody(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: widget.actionButtons != null
                  ? Row(
                      children: widget.actionButtons!,
                    )
                  : Container(),
            ),
          ],
        ),
      );
      mapHooks.refetch();
      return card;
    }
    return Container();
  }

  // builds the actual webview widget
  Widget buildBody(context) {
    print('webview_container:buildBody: ' + webCardUrl!);
    return Container(
      height: _contentHeight,
      child: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: webCardUrl,
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        navigationDelegate: null,
        javascriptChannels: <JavascriptChannel>[
          _linksChannel(context),
          _heightChannel(context),
          _mapChannel(context),
          _refreshTokenChannel(context),
          _permanentRedirect(context)
        ].toSet(),
      ),
    );
  }

  Widget? buildMenu() {
    if (widget.hideMenu ?? false) {
      return Container();
    }
    return ButtonBar(
      buttonPadding: EdgeInsets.all(0),
      mainAxisSize: MainAxisSize.min,
      children: [
        buildMenuOptions({
          CardMenuOptionConstants.reloadCard: _webViewController?.reload,
          CardMenuOptionConstants.hideCard: hide,
        }),
      ],
    );
  }

  Widget buildMenuOptions(Map<String, Function?> menuOptions) {
    List<DropdownMenuItem<String>> menu = [];
    menuOptions.forEach((menuOption, func) {
      Widget item = DropdownMenuItem<String>(
        value: menuOption,
        child: Text(
          menuOption,
          textAlign: TextAlign.center,
        ),
      );
      menu.add(item as DropdownMenuItem<String>);
    });
    return DropdownButton(
      items: menu,
      underline: Container(),
      icon: Icon(Icons.more_vert),
      onChanged: (String? selectedMenuItem) =>
          onMenuItemPressed(selectedMenuItem),
    );
  }

  void onMenuItemPressed(String? selectedMenuItem) {
    switch (selectedMenuItem) {
      case CardMenuOptionConstants.reloadCard:
        {
          _webViewController?.loadUrl(webCardUrl!);
        }
        break;
      case CardMenuOptionConstants.hideCard:
        {
          hide!();
        }
        break;
      default:
        {
          // do nothing for now
        }
    }
  }

  // channel for opening links
  JavascriptChannel _linksChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'OpenLink',
      onMessageReceived: (JavascriptMessage message) {
        openLink(message.message);
      },
    );
  }

  // channel for dynamically setting the height of the card
  JavascriptChannel _heightChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'SetHeight',
      onMessageReceived: (JavascriptMessage message) {
        setState(() {
          _contentHeight =
              validateHeight(context, double.tryParse(message.message));
        });
      },
    );
  }

  // channel for performing a map search based on given query
  JavascriptChannel _mapChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'MapSearch',
      onMessageReceived: (JavascriptMessage message) {
        // navigate to map and search with message.message
        Provider.of<MapsDataProvider>(context, listen: false)
            .searchBarController
            .text = message.message;
        Provider.of<MapsDataProvider>(context, listen: false).fetchLocations();
        Provider.of<BottomNavigationBarProvider>(context, listen: false)
            .currentIndex = NavigatorConstants.MapTab;
        Provider.of<CustomAppBar>(context, listen: false).changeTitle("Maps");
        //Navigator.pushNamed(context, RoutePaths.Map);
      },
    );
  }

  JavascriptChannel _refreshTokenChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'RefreshToken',
      onMessageReceived: (JavascriptMessage message) async {
        if (!Provider.of<UserDataProvider>(context, listen: false).isLoggedIn) {
          if (await _userDataProvider.silentLogin()) {
            _webViewController?.reload();
          }
        }
      },
    );
  }

  // javascript channel for redirecting the user to a new webcard URL
  JavascriptChannel _permanentRedirect(BuildContext context) {
    return JavascriptChannel(
      name: 'Redirect',
      onMessageReceived: (JavascriptMessage message) async {
        webCardUrl = message.message;
        _webViewController!.loadUrl(message.message);
      },
    );
  }

  // this function checks to see if the current url of the state is different
  // to the webViewController's url, and loads in the new url if so
  void checkWebURL() async {
    String? currentUrl = await _webViewController?.currentUrl();
    if (_webViewController != null && webCardUrl != currentUrl) {
      _webViewController?.loadUrl(webCardUrl!);
    }
  }
}
