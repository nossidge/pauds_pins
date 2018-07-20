# Paud's Pins

* Badges curated by Paud Hegarty
* Photography by [Gavin McGregor](https://twitter.com/gawanmac)
* This code by [Paul Thompson](https://twitter.com/nossidge)


## About the pins

[Paud's Pins – a queer history project][pauds_pins] is a website created by
[Gavin McGregor][gawanmac] that catalogues a discovery made in the attic of
his friend Louise's south London flat.

It's a set of 205 gay/lefty pin badges from the 1970s/80s, collected by Paud
Hegarty, a former manager of [Gay's the Word][gays_the_word] bookshop in
Bloomsbury. Gavin has photographed and described each one of them.

I (Paul Thompson) thought this was super-cool, and wanted to see if I could
do something vaguely arty-ish with the badges. They are presented as JPEGs on a
white background, so I figured it should be easy enough to download them all,
add background transparency, and re-arrange them as a [collage][collage].

This repo shares the code I used and the URLs of the resulting PNGs, so
you don't have to duplicate the site-scraping or image conversion. This is
available in a [JSON file][json].

[pauds_pins]: https://paudspins.wordpress.com/
[gawanmac]: https://twitter.com/gawanmac
[gays_the_word]: http://gaystheword.co.uk
[collage]: https://tilde.town/~nossidge/pins/
[json]: https://raw.githubusercontent.com/nossidge/pauds_pins/master/data/pins.json


## Description of code

This repo contains code to perform the following:

* Scrape the pin images from paudspins.wordpress.com
* Convert to PNG with background transparency
* Compress to smaller PNG
* Upload PNGs to Imgur
* Store a JSON file containing metadata and Imgur URLs


## Output JSON

The [JSON file][json] contains an array of hashes describing each pin and
listing the image URLs.

    [
      {
        "title": "‘Gay’ – silver",
        "category": "Just Gay",
        "filename": "gay-1-ws",
        "page": "https://paudspins.wordpress.com/portfolio/just-gay/gay-1-ws/",
        "jpg": "https://paudspins.files.wordpress.com/2018/05/gay-1-ws.jpg",
        "png_orig": "https://i.imgur.com/xDngt5R.png",
        "png_x320": "https://i.imgur.com/rSDaEYu.png"
      }
    ]


## Running the code

You don't need to run the code, it's already been done!

The output is in the [JSON file][json].

But if you do want to play around with it, you can install the dependencies
like this:

    git clone https://github.com/nossidge/pauds_pins.git
    cd pauds_pins
    bundle install

You'll need an [Imgur API][imgur] token stored in the `IMGUR_CLIENT_ID`
environment variable, and [ImageMagick][imagick] installed and in your path.

[imgur]: https://apidocs.imgur.com
[imagick]: https://github.com/ImageMagick/ImageMagick


## Acknowledgements

* [Paud Hegarty](https://paudspins.wordpress.com/about/)
* [Gay's the Word](http://gaystheword.co.uk)
* [Gavin McGregor](https://twitter.com/gawanmac/status/1013161024244125696)
* Everyone listed [here](https://paudspins.wordpress.com/thanks/)


## Licences

* Code licensed under [GNU General Public License v3.0][gpl3]
* Photographs by Gavin McGregor, and available for non-commercial re-use
* Image reproduction and usage info is [here][image-use]

[gpl3]: https://www.gnu.org/licenses/gpl-3.0.en.html
[image-use]: https://paudspins.wordpress.com/media/use-of-images/
