---
title: 'Exploring The Deutsche Telekom Jobsite.'
pubDate: 2024-04-24 
description: 'The long overdue CSS fix. And the surprise Disney effect.'
author: 'Bence Madar'
tags: ["debug", "junior", "jquery"]
contentSize: "~2mb"
assetCount:
    images: '5'
    videos: '2'
---

<img src="/src/assets/posts//1-tkom/hero.png" alt="Initial bugged CSS.">

## Unpleasant morning coffees.

Not that long ago I developed an intimate relationship with the buggy CSS seen in the above image. I've spent a few of my morning coffee hours looking through Deutsche Telekom's job offerings, and I did not enjoy the experience. At this point, not even because of their horrendous job requirements. That comes later, it’s definitely worth its separate post. I’ll get to that someday.

Staring at those broken filters each morning, looking deeper and deeper into those ugly collapsing lines, how text and colour are squeezed together, merging into this abomination. An abomination of my past memories. Reminding me of my lifetime front-end application rejections from businesses like them. Never being good enough.

I kept thinking it can't be only me - not as “not being good enough”, as I’m sure there are a lot of us out there who were told this countless times -. As in, someone must have noticed this bug a long time ago too, it surely gets a quick fix soon. This was roughly 2 months ago,

<p class="middle"><span>and that thing, to this day, keeps staring right back at me.</span></p>

Didn’t help to look it up on the wayback machine either. <a href="https://web.archive.org/web/20230922203632/https://www.deutschetelekomitsolutions.hu/en/open-positions/">It’s like that for almost a year.</a> That’s as far as I had the patience to go back. 

I couldn't really find a position I was interested in. But I've found other things. The need to fix these. And show everyone, who may be living in this delusion of not being good enough. 

<p class=”middle”>There are things out there. Very expensive things, not good enough either. From Very Serious Businesses.</p>

## No mistakes here, just happy little accidents.

I’m not sure if this CSS was coming from a deprecated, or version bumped library like Bootstrap (I'm not going to call it a framework), or these filters were just implemented later, not even considering the potential line break. Which would be my guess, for it’s quite the work to add all the tags on desktop view to break it. A band aid solution of sorts to a “can we get this done by yesterday” request. I know those requests well. This is why my money is on the latter part, especially as we continue to dive in.

<img src="/src/assets/posts//1-tkom/image1-min.png" alt="Initial bugged CSS.">

<p class="middle"><span>So I fixed it with three lines of CSS.</span></p>

Just quickly throwing some flex properties at it.

```css
display:flex;
flex-wrap:wrap;
gap:12px;
```

Now I could also use the removal of unnecessary margins, some modified paddings to accommodate the new flex properties, but I’m not going to include those. I already feel like I should be sending the contractor bill of 30,000 Euros for my efforts.

The CSS:after.

<img src="/src/assets/posts//1-tkom/image4-min.png" alt="asd">

<p class="middle"><span>Ticket closed. Good bye. You’re welcome, little CSS.</span></p>

## The Disney effect.

A few days later I decided to go back and take some screenshots for reference. You know, before they rush in and fix it. Seriously you never know with these things. You start writing about it for fun and the next day it’s gone.

I’ve done some filter clicking to reproduce it, started taking my precious shots and planned on calling it a day.

Then I noticed when I cleared all the filters with the Delete filters button, I didn't get all the available positions back. Should have been around 180 ish. But it only returned 15. So I started clicking like a madman. Sometimes it returned the correct 180 ish. Often other numbers. 15, 60, or 9.. numbers not 180 ish. Clicking the left sidebars input fields one by one did not reproduce the issue. So what’s the magic of the Delete Filters button? Because that one does the trick, and does it consistently. 

<video width="100%" controls>
    <source src="/src/assets/posts//1-tkom/vidfor8.mp4">
</video>

**Count from response doesn’t equal to rendered results.**

<img src="/src/assets/posts//1-tkom/image5-min.png" alt="asd">

I checked the dev console's requests and responses. The numbers were okay. The last response always had the correct `count` value.

At this exact point I felt I should just click the red X in the top right corner and leave the room, leave the house. 

<p class="middle">So I did what had to be done.</p>

<details open>
    <summary>hide</summary>
    <img src="/src/assets/images/gearup.gif">
</details>

I dug up all the JavaScript files that could be responsible for this issue. I spent some more time checking the network requests and responses but they were fine. I checked the jQuery render function that takes in the response and..

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
        jQuery('.tsystemjobs_result_indicator_inner').find('.counter').html(response.count);
        jQuery("#tsystemjobs_resultcount").html(response.count);
        jQuery("#tsystemsjobs_results").removeClass('hidden');
...
```
However I could feel this render function was not set up to handle multiple, almost simultaneous responses, which we’ll get on the all tag removals. Hence my above note, guessing if these tags were a later, quick addition to an already implemented codebase. Built to be used with the left side filters only.

By this point I was able to confirm that the render takes in the wrong response, a value from one of the previous responses.

<p class="middle"><span>tl;dr anyway let's call it a "render-race condition".</span></p> 

<p>It's a good name. Also if you change one letter in the first word, you get the secret sauce of 2019+ Disney movie failures. What were the base conditions of every Disney movie lately?</p>

<p>On a serious note, you can also check an absorb the context of ${this}. The below ${this} references the above .remove() and .click() functions.</p>

```javascript
// these functions click the button to refresh the search FOR EACH tag removed
    $('.search_tags').find('.'+elementid).remove();
    $('#tsystemsjobs_advancedsearchbutton').click();
}
// hidden button included for reference
// <button class="button medium hidden" id="tsystemsjobs_advancedsearchbutton">Search for jobs</button>

//.reset is the button that removes all the tags
// does a button click for each search tag element.
$('.reset').on('click',function(){
$('.search_tags').children('span').each(function(){
        $(this).click();
    });
});
```

**The issue in human language:**

Whenever you press the Delete Filters button, the jQuery function targets each single filter element, removes it from the view, and asks the server for a response. It keeps doing this for each single filter tag you applied, sending a request for each tag removal. These single filter tag removals happen quite fast, so all the requests sent by them happen almost simultaneously. Whichever of these filter requests get back to the above included render function first will be the winner of the race, and gets to be the king of the screen.

<img src="/src/assets/posts//1-tkom/image8-min.png" alt="asd">

You can play with it<a href="https://www.deutschetelekomitsolutions.hu/en/open-positions/">here.</a>

Something should be throttled, timed out, debounced, whatever you call it.

### Credit where credit is due.

It's great to see a jQuery/WordPress site from the 2010s, still in prod. Even if <a href="https://web.archive.org/web/20201124150805/https://www.deutschetelekomitsolutions.hu/karrier/nyitott-poziciok/">the site looks to be from 2020.</a>, I'm sure it was just copied over from the previous NotDeutscheTelekomITServices implementation. At least that’s what I would have done if I had a perfectly fine, working site base. Don’t reinvent the wheel. A good example of not needing a hot new framework for everything to exist and be functional, even in 2024. 

<p class=”middle”>Well, mostly functional.</p>

## Until next time, my sweet Magenta Princess.
