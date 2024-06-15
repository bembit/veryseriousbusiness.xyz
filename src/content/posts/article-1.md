---
title: 'Something Special - The Deutsche Telekom Jobsite.'
pubDate: 2024-04-24 
description: 'The long overdue CSS fix. And a surprise discovery.'
author: 'Bence Madar'
tags: ["debug", "junior", "jquery"]
contentSize: "~ 1mb"
assetCount:
    images: '5'
    videos: '1'
---

<img src="https://pub-d6c34ccb68414a5bbfe746e44b7811ff.r2.dev/1-tkom/hero.png" alt="Initial bugged CSS.">

## _f4cksGiven <= 0

Not so long ago I developed an intimate relationship with this buggy CSS. I've spent a few of my morning coffee hours looking through Deutsche Telekom's job offerings, and I did not enjoy the experience. At this point, not even because of their horrendous requirements. That comes later, as it’s definitely worth its own post. Fitting all the junior framework dev roles with added kubernetes requirements would make this post quite long, and overwhelmingly ranty. So, for this first post let's stick with *not enjoying the experience*.

Staring at those broken filters each morning, I couldn't help but think. Someone must have noticed this a long time ago too, it surely gets a fix soon. This was roughly 3 months ago, and that thing, to this day, keeps staring right back at me. Then of course I had to look it up on the wayback machine. It’s like that for <a href="https://web.archive.org/web/20230922203632/https://www.deutschetelekomitsolutions.hu/en/open-positions/">almost a year.</a> That’s as far as I had the patience to dig back to.

Sadly, I couldn't find a position I was interested in. But I've found something else.

What? The need to document these meaningless frontend findings? Well, no. I've got that going for a while now. More like the balls to start blogging said findings. 

Why? Because why the fuck not?


## No mistakes here, just happy little accidents.

I’m not sure if this CSS was coming from a deprecated / version bumped library like Bootstrap, or if these filters were just implemented later, not even considering the potential line break. Which would be my guess, for it’s quite the work to add all the tags on desktop view to break it. A band aid solution of sorts to a “can we get this done by yesterday” request. I know those requests well.

<img src="https://pub-d6c34ccb68414a5bbfe746e44b7811ff.r2.dev/1-tkom/image1-min.png" alt="Initial bugged CSS.">

<p class="middle"><span>So I fixed it with three lines of CSS.</span></p>

By throwing some flex properties at it.

```css
display:flex;
flex-wrap:wrap;
gap:12px;
```

It could also use the removal of unnecessary margins, and some modified paddings to accommodate the new flex properties, but I’m not going to include those.

The CSS:after.

<img src="https://pub-d6c34ccb68414a5bbfe746e44b7811ff.r2.dev/1-tkom/image4-min.png" alt="asd">

<p class="middle"><span>Ticket closed. Good bye. Good bye?</span></p>

## But wait, there's more!

A few days later I decided to go back and take some screenshots for reference. You know, before they rush in and fix it. I’ve done some filter clicking, started taking my precious shots and planned on calling it a day.

I noticed while I cleared all the filters with the Delete filters button, I didn't get all the available positions back. The number should have been around 180 ish. But it only returned 15. So I started an input / filter clicking frenzy. Sometimes it returned the correct 180 ish. Often other numbers. 15, 60, or 9.. numbers not 180 ish. Clicking the left sidebars input fields one by one did not reproduce the issue. So what’s the magic of the Delete Filters button? Because that one does the trick, and does it consistently.

You can play with it <a href="https://www.deutschetelekomitsolutions.hu/en/open-positions/">here.</a>

<video width="100%" controls>
    <source src="https://pub-d6c34ccb68414a5bbfe746e44b7811ff.r2.dev/1-tkom/vidfor8.mp4">
</video>

**Count from response doesn’t equal to rendered results.**

<img src="https://pub-d6c34ccb68414a5bbfe746e44b7811ff.r2.dev/1-tkom/image5-min.png" alt="asd">

I checked the dev console's requests and responses. The numbers were okay. The last response always had the correct `count` value.

At this exact point I felt I should just click the red X in the top right corner and leave the room, leave the house. 

So I dug up all the JavaScript files that could be responsible for this issue. I spent some more time checking the network requests and responses but they were fine. I checked the jQuery render function that takes in the response and..

It looked good to me.

```javascript
jQuery.ajax({
    url: tsystemsjobs.ajax_url,
    type: 'post',
    data: payLoad,
    dataType: "json",
    success: function (response) {
        jQuery("#loadingoverlay").hide();
        // set resultcount
        jQuery('.tsystemjobs_result_indicator_inner')
            .find('.counter').html(response.count);
        jQuery("#tsystemjobs_resultcount").html(response.count);
        jQuery("#tsystemsjobs_results").removeClass('hidden');
...
```
However I could feel this render function was not set up to handle multiple, almost simultaneous responses, which we get on the all tag removals. Hence my above note, guessing if these tags were a later, quick addition to an already implemented codebase. I'm pretty sure the initial design was for the site to be used with the left side navigation's filters only.

So the render takes in the wrong response, a value from one of the previous responses.

<p class="middle"><span>Let's call this a "render-race condition".</span></p> 

<p>The below ${this} references the upper .remove() and .click() functions.</p>

```javascript
// these functions click the button to refresh the search FOR EACH tag removed
    $('.search_tags').find('.'+elementid).remove();
    // hidden button in dom
    $('#tsystemsjobs_advancedsearchbutton').click();
}
//.reset is the button that removes all the tags
// does a button click for each search tag element.
$('.reset').on('click',function(){
    $('.search_tags').children('span').each(function(){
            $(this).click();
        });
    });
```

**The issue described using human language**

Whenever you press the Delete Filters button, the function targets each single filter element, removes it from the view, and asks the server for a response. It keeps doing this for each single filter tag you applied, sending a request for each tag removal. These single filter tag removals happen quite fast, so all the requests sent by them happen almost simultaneously. Whichever of these filter requests get back to the above included render function first will be the winner of the race, and gets to be the king of the screen.

<img src="https://pub-d6c34ccb68414a5bbfe746e44b7811ff.r2.dev/1-tkom/image8-min.png" alt="asd">

There are some approaches to this fix. Not even considering the backend we have no access to. I think it should be debounced with an approach like the half-pseudo code below.

```javascript
// implement a debounce func that matches the current environment
...
// separate the button .click() from the .remove() func
function advancedSearchButton() {
    $('#tsystemsjobs_advancedsearchbutton').click();
}
...
var debounceIt = debounce(advancedSearchButton, 300);
// remove all the tags
$('.reset').on('click', function() {
    $('.search_tags').children('span').each(function() {
        $(this).remove();
    });
    // when all the tags are removed, click the debounced search button
    debounceIt();
});
...
```

There must be a good way to handle it as one request instead of sending the current `filters * request`. This is just my initial thought. I already spent way more time on this site than I should have. Even my dark theme is magenta like. Please send help.

### Credit where credit is due.

It's great to see a jQuery/WordPress site from the 2010s, still in prod. Even if the site looks to be <a href="https://web.archive.org/web/20201124150805/https://www.deutschetelekomitsolutions.hu/karrier/nyitott-poziciok/">from 2020,</a> I'm sure it was just copied over from the previous NotDeutscheTelekomITServices implementation. At least that’s what I would have done if I had an already working site base. A good example of not needing a hot new framework for everything to exist and be functional, even in 2024.

<p class=”middle”>Well, mostly functional.</p>

## Until next time, my sweet Magenta Princess.
