import 'package:campus_mobile_experimental/core/hooks/map_query.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

class SearchHistoryList extends HookWidget {
  const SearchHistoryList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapHook = useFetchMapModel();
    return Flexible(
      child: Card(
        margin: EdgeInsets.all(5),
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(height: 0),
          itemCount:
              Provider.of<MapsDataProvider>(context).searchHistory.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              leading: Icon(Icons.history),
              title: Text(Provider.of<MapsDataProvider>(context)
                  .searchHistory
                  .reversed
                  .toList()[index]),
              trailing: IconButton(
                iconSize: 20,
                icon: Icon(Icons.cancel),
                onPressed: () {
                  Provider.of<MapsDataProvider>(context, listen: false)
                      .removeFromSearchHistory(
                          Provider.of<MapsDataProvider>(context, listen: false)
                              .searchHistory
                              .reversed
                              .toList()[index]);
                },
              ),
              onTap: () {
                Provider.of<MapsDataProvider>(context, listen: false)
                        .searchBarController
                        .text =
                    Provider.of<MapsDataProvider>(context, listen: false)
                        .searchHistory
                        .reversed
                        .toList()[index];
                mapHook.refetch();
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}
