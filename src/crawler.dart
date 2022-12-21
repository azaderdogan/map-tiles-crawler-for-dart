/// read crawler.js and convert to dart code

/**

function Crawler () {
    this.tileSize = 256;
    this.urlTemplate = /\{ *([xyz]) *\}/g;   
    this.pathTemplate = /\{ *([xyz]) *\}.*?\{ *([xyz]) *\}.*?\{ *([xyz]) *\}.*?(\.[a-zA-Z]{3,4})/;
}

Crawler.prototype.selectProtocol = function(url) {
    if (url.search(/^http:\/\//) === 0) {
        return http;
    } else if (url.search(/^https:\/\//) === 0) {
        return https;
    } else {
        return null;
    }
}
Crawler.prototype.downloadFile = function(source, target) {
    return new Promise((resolve, reject) => {
        try {
            var dirname = path.dirname(target);
            mkdirp(dirname, (err) => {
                var file = fs.createWriteStream(target);
                this.selectProtocol(source).get(source, function(resp) {                    
                    file.once('finish', () => {
                        file.close();
                        resolve();
                    });
                    resp.pipe(file);                    
                });
            });
        } catch(e) {
            reject();
        }
    }); 
};

Crawler.prototype.calculateRect = function(topLeft, bottomRight, level) {
    var topLeftTile = this.calculateTileCoordinates(topLeft.latitude, topLeft.longitude, level);
    var bottomRightTile = this.calculateTileCoordinates(bottomRight.latitude, bottomRight.longitude, level);

    return {
        startX : topLeftTile.x ,
        startY : topLeftTile.y ,
        endX : bottomRightTile.x ,
        endY : bottomRightTile.y ,
        level : level
    };
};

Crawler.prototype.calculateTileCoordinates = function(latitude, longitude, level) {
    var sinLatitude = Math.sin(latitude * Math.PI / 180);
    var pixelX = ((longitude + 180) / 360) * this.tileSize * Math.pow(2, level);
    var pixelY = (0.5 - Math.log((1 + sinLatitude) / (1 - sinLatitude)) / (4*Math.PI)) * this.tileSize * Math.pow(2,level);

    return {
        x : Math.floor(pixelX / this.tileSize) ,
        y : Math.floor(pixelY / this.tileSize) ,
        z : level
    };
};


Crawler.prototype.getPaths = function (url, tile, targetPrefix = '') {
    var result = {source:null, target:null};
    var path = url.match(this.pathTemplate);

    if (path) {
        result.source = this.replacePath(url, tile);
        result.target = targetPrefix + this.replacePath("{" + path[1] + "}/{" + path[2] + "}/{" + path[3] + "}" + path[4], tile)
    }

    return result;
};

Crawler.prototype.replacePath = function(url, data) {
    return url.replace(this.urlTemplate, (str, key) => {
        return data[key];
    });
};


Crawler.prototype.crawlRect = function(rect, url, folder, current) {
    if (!current) {
        current = {
            x : rect.startX ,
            y : rect.startY ,
            z : rect.level
        };
    }

    var paths = this.getPaths(url, current, folder);
    this.downloadFile(paths.source, paths.target)
        .then(() => {
            if (this.progress) {
                this.progress(current);
            }

            // next y
            if (current.x >= rect.endX && current.y >= rect.endY) {
                if (this.success) {
                    this.success();
                    return;
                }
            } else if (current.x >= rect.endX && current.y < rect.endY) {
                current.y += 1;
            }

            // next x
            if (current.x >= rect.endX) {
                current.x = rect.startX;
            } else {
                current.x += 1;
            }

            setTimeout(() => {
                this.crawlRect(rect, url, folder, current);
            }, this.wait);                     
        })
        .catch(() => {
            if (this.error) {
                this.error(current);
            }
        });
};


Crawler.prototype.crawl = function(options) {
    var options = options || {};

    var topLeft = {
        latitude : parseFloat(options.topLeft[0]) ,
        longitude : parseFloat(options.topLeft[1])
    };

    var bottomRight = {
        latitude : parseFloat(options.bottomRight[0]) ,
        longitude : parseFloat(options.bottomRight[1])
    };

    this.wait = options.wait || 0;
    this.success = options.success;
    this.error = options.error;
    this.progress = options.progress;

    this.crawlRect(this.calculateRect(topLeft, bottomRight, options.level), options.url, options.targetFolder);
};
 */

import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as pathx;
import 'dart:math' as math;

class Crawler {
  int tileSize = 256;
  RegExp urlTemplate = RegExp(r'\{ *([xyz]) *\}');
  RegExp pathTemplate = RegExp(
      r'\{ *([xyz]) *\}.*?\{ *([xyz]) *\}.*?\{ *([xyz]) *\}.*?(\.[a-zA-Z]{3,4})');

  selectProtocol(String url) {
    if (url.startsWith('http://')) {
      return HttpClient();
    } else if (url.startsWith('https://')) {
      return HttpClient();
    } else {
      return null;
    }
  }

  Future downloadFile(String source, String target) async {
    try {
      var dirname = pathx.dirname(target);
      await Directory(dirname).create(recursive: true);
      var file = File(target);
      var httpClient = selectProtocol(source);
      print('Downloading $source');
      var request = await httpClient.getUrl(Uri.parse(source));
      var response = await request.close();
      await response.pipe(file.openWrite());
    } catch (e) {
      print(e);
    }
  }

  calculateRect(topLeft, bottomRight, level) {
    print(topLeft);
    print(bottomRight);
    print(level);
    var topLeftTile = calculateTileCoordinates(
        topLeft['latitude'], topLeft['longitude'], level);
    var bottomRightTile = calculateTileCoordinates(
        bottomRight['latitude'], bottomRight['longitude'], level);

    return {
      'startX': topLeftTile['x'],
      'startY': topLeftTile['y'],
      'endX': bottomRightTile['x'],
      'endY': bottomRightTile['y'],
      'level': level
    };
  }

  calculateTileCoordinates(latitude, longitude, level) {
    var sinLatitude = math.sin(latitude * math.pi / 180);
    var pixelX = ((longitude + 180) / 360) * this.tileSize * math.pow(2, level);
    var pixelY = (0.5 -
            math.log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * math.pi)) *
        this.tileSize *
        math.pow(2, level);

    return {
      'x': (pixelX / this.tileSize).floor(),
      'y': (pixelY / this.tileSize).floor(),
      'z': level
    };
  }
  /**
   * Crawler.prototype.getPaths = function (url, tile, targetPrefix = '') {
    var result = {source:'', target:''};
    var path = url.match(this.pathTemplate);

    if (path) {
        result.source = this.replacePath(url, tile);
        result.target = targetPrefix + this.replacePath("{" + path[1] + "}/{" + path[2] + "}/{" + path[3] + "}" + path[4], tile)
    }

    return result;
};

   */

  getPaths(url, tile, targetPrefix) {
    var result = {'source': '', 'target': ''};
    var path = pathTemplate.firstMatch(url);

    if (path != null) {
      result['source'] = replacePath(url, tile);
      result['target'] = targetPrefix +
          replacePath(
              "/{" +
                  path.group(1)! +
                  "}/{" +
                  path.group(2)! +
                  "}/{" +
                  path.group(3)! +
                  "}" +
                  path.group(4)!,
              tile);
    }
    return result;
  }

  /**
   * 
Crawler.prototype.replacePath = function(url, data) {
    return url.replace(this.urlTemplate, (str, key) => {
        return data[key];
    });
};

   */
  String replacePath(String url, Map data) {
    print('replacePath');
    print('url: $url');
    print('data: $data');
    // url.replace(this.urlTemplate, (str, key) => { return data[key]; });
    return urlTemplate.allMatches(url).fold(url, (url, match) {
      print('match: $match');
      print('group: ${match.group(1)}');
      print('data: ${data[match.group(1)]}');
      return url.replaceFirst(
          match.group(0)!, data[match.group(1)]!.toString());
    });
  }

  crawlRect(rect, url, folder, current) {
    if (current == null) {
      current = {'x': rect['startX'], 'y': rect['startY'], 'z': rect['level']};
    }

    var paths = getPaths(url, current, folder);
    print('paths: $paths');
    downloadFile(paths['source'], paths['target']).then((_) {
      // next y
      if (current['x'] >= rect['endX'] && current['y'] >= rect['endY']) {
        return;
      } else if (current['x'] >= rect['endX'] && current['y'] < rect['endY']) {
        current['y'] += 1;
      }

      // next x
      if (current['x'] >= rect['endX']) {
        current['x'] = rect['startX'];
      } else {
        current['x'] += 1;
      }

      crawlRect(rect, url, folder, current);
    }).catchError((e) {
      print(e);
    });
  }

  crawl(options) {
    var topLeft = {
      'latitude': options['topLeft'][0],
      'longitude': options['topLeft'][1]
    };

    var bottomRight = {
      'latitude': (options['bottomRight'][0]),
      'longitude': (options['bottomRight'][1])
    };

//    this.crawlRect(this.calculateRect(topLeft, bottomRight, options.level), options.url, options.targetFolder);

    crawlRect(
      calculateRect(topLeft, bottomRight, options['level']),
      options['url'],
      options['targetFolder'],
      null,
    );
  }
}

/**
 * var crawler = require('map-tiles-crawler');
crawler.crawl({
    url: 'http://maps.wien.gv.at/basemap/bmaporthofoto30cm/normal/google3857/{z}/{y}/{x}.jpeg' ,
    targetFolder: './.tmp' ,
    level : 18 ,
    topLeft: [47.46575119, 11.92384601] ,
    bottomRight: [47.46068834, 11.91423297] ,
    wait: 100 ,
    progress : (tile) => { // callback after tile download } ,
    success : () => { // callback after all tiles are downloaded } ,
    error : (tile) => { // callback if a tile couldn't be downloaded }
});

 */

void main(List<String> args) {
  var crawler = Crawler();
  crawler.crawl({
    'url':
        'http://maps.wien.gv.at/basemap/bmaporthofoto30cm/normal/google3857/{z}/{y}/{x}.jpeg',
    'targetFolder': '.tmp',
    'level': 18,
    'topLeft': [47.46575119, 11.92384601],
    'bottomRight': [47.46068834, 11.91423297],
  });
}
