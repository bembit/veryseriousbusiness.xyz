---
title: 'Exploring The Deutsche Telekom Jobsite.'
pubDate: 2024-04-24 
description: 'A long overdue CSS fix. A race condition. And lots of ranting.'
author: 'Bence Madar'
tags: ["opinion", "debug", "nsfw","junior"]
---
<img src="https://pub-d6c34ccb68414a5bbfe746e44b7811ff.r2.dev/1-tkom/hero.png" alt="Initial bugged CSS.">

## Part 1 - Casually looking.

I developed a very intimate relationship with the buggy CSS seen in the above image. I've spent a few of my morning coffee hours looking through Deutsche Telekom's job offerings. I remember I kept thinking someone must have noticed this bug a long time ago, and it surely gets fixed any minute now. This was roughly 2 months ago.

<p class="middle"><span>And that thing, to this day, keeps staring right back at me.</span></p>

Fortunately I couldn't really find a position I was interested in, but I managed to find something better. A great job posting, not just perfectly capturing the 2023+ job market trends, **but also one of the main reasons I started writing this article.** Because it sure wasn’t for a one-liner CSS fix, nor for a race condition. But we'll get to those a bit later too. Or you can just scroll to Part 3 now.

## Part 2 - My problem with these.

<details>
    <summary>click to open - <b>your average junior angular dev</b></summary>
    <img src="https://pub-d6c34ccb68414a5bbfe746e44b7811ff.r2.dev/1-tkom/image2-min.png" alt="Your average junior angular developer job ad.">
</details>

It's worth a full read for sure, it's one of those perfect cut, **fuck off** diamond listings, but let me summarise it in case you hate reading these, like I do:

- ...including simple rule-based models and machine learning algorithms.
- Bachelor's or Master's degree in computer science or related field or equivalent work experience.
- 2 years of IT experience in the whatever.js ecosystem.
- Fluent in a frontend framework (typescript/node/angular). - Angular is a framework, yes.
- Experience in AWS.
- Experience in UI/UX design.
- Experience in Cypress, Jest. - Casually add in 2 testing frameworks too.
- And all the extra corporate stuff that has "stakeholder relations" in it. - Since you'll be a junior developer.

These requirements combined with the "advantages" translate to a very strong medior role. Considering we are looking at the Hungarian market, this quite easily could translate to a strong Senior role. And any senior would say a "see ya later" to this mess.

One honorable mention is.
- Experience with Jira / Confluence.

Very important to emphasize the need for Jira and Confluence in general, regardless of seniority level, after writing code for years, decades *- or remember when even installing operating systems were full weekend projects? -*,

<p class="middle"><span>I'm certain Jira will be our downfall. And all those scary, clicky-clicky drag and drop tools.</span></p>

But my favourite part is.
- Experience with Docker/Kubernetes/DevOps.

You just used the "no-no" word that makes anyone with a bit of common sense immediately terminate all running browser processes. You have to ease us, lure ( or lube ) us in during the 2nd or 3rd stage of the interview process. "Heeeey, would you mind doing some Docker for internal stuff?". But even then, you shouldn't mention Kubernetes, especially in a ~~senior angular & devops/sysops architect~~ junior angular role like this one.

Business truly doesn't give a shit anymore right? Asking for these junior skills is just taking the piss, isn't it Deutsche Telekom? Imagine the likes of me reading this with those filters in our faces, thinking "Yeah, sure I'd definitely work there, where do I sign?"

Not that I'd apply to it. But there are juniors out there who will. Should this really be the place where they get told they are not good enough?

<p class="middle"><span>"Thanks for applying, your frontend sucks. -Kind regards, our recruitment site with easy to spot CSS bugs and race conditions."</span></p>

<br>

If they try to reach and hire the best of the best, one would rightfully think they take the representation of their business seriously, especially **with assets valued (as of 2022) around 300 billion Euros.** Of course I could be wrong and this is completely normal, because the current market favours businesses over employees.

In my opinion, these requirements don’t match their public facing career site.

 **Let me give you a good job advert example from Tesco,** It's clear, and on point. And with this, I'm done.

- Software Development Engineer (JavaScript) @ Tesco, from LinkedIn.

<img src="https://pub-d6c34ccb68414a5bbfe746e44b7811ff.r2.dev/1-tkom/tesco.png" alt="Initial bugged CSS.">

## Part 3 - For god's sake just shut up and fix it already.


Ok. The filters looked bad and I thought I would check what this insanely complex issue might be. Why can't they spare the “months” of developer time to fix it.

<img src="https://pub-d6c34ccb68414a5bbfe746e44b7811ff.r2.dev/1-tkom/image1-min.png" alt="Initial bugged CSS.">

**So I fixed it with three lines of CSS.**

*This could have been easily added a few weeks ago when your entire prod site was down for 4 days.*

<p class="middle"><span>Three lines of CSS and I'll never start a blog.</span></p>

```css
display:flex;
flex-wrap:wrap;
gap:12px;
```

I wasn’t sure if this was some bootstrap issue that developed over time, or these filters were just implemented later. A band aid solution of sorts to the request of an overzealous PM. My money is on the latter part, as we continue to dive in. Later I checked it on the wayback machine. It’s like this for almost a year, <a href="https://web.archive.org/web/20230922203632/https://www.deutschetelekomitsolutions.hu/en/open-positions/">here's the link,</a> if you care.


The CSS:after.

<img src="https://pub-d6c34ccb68414a5bbfe746e44b7811ff.r2.dev/1-tkom/image4-min.png" alt="asd">

<p class="middle"><span>Ticket closed. Good bye.</span></p>

## Part 4 - Wait, there’s more!

A few days later I decided to go back and take some screenshots, just for reference. You know, before they rush in and fix it..
I’ve done some filter clicking to reproduce it, took some shots and planned on calling it a day.

I noticed when I remove all the filters, I don’t always get all the available positions back. Should have been around 180 ish. Sometimes it returned 15, 60, or 9.. numbers not 180 ish. Clicking the left sidebars input fields one by one did not reproduce the issue. So what’s the magic in the Delete Filters button? Because that one does the trick, and does it consistently. 

<video width="100%" controls>
    <source src="https://pub-d6c34ccb68414a5bbfe746e44b7811ff.r2.dev/1-tkom/vidfor8.mp4">
</video>

Count from response doesn’t equal to rendered results.

<img src="https://pub-d6c34ccb68414a5bbfe746e44b7811ff.r2.dev/1-tkom/image5-min.png" alt="asd">

I checked the dev console's requests and responses. The numbers were okay. The last response always had the correct `count` value.

At this exact point I felt I should just click the red X in the top right corner and leave the room, leave the house. So I dug up all the JavaScript files that could be responsible for this issue. I spent some more time checking the network requests and responses but they were fine. I checked the jQuery render function that takes in the response and..

It looked good to me.

<img src="https://pub-d6c34ccb68414a5bbfe746e44b7811ff.r2.dev/1-tkom/image6-min.png" alt="asd">

Here I was able to confirm that it takes the wrong response, usually the value from the previous response. Or in some cases from responses even before.

<p class="middle"><span>tl;dr anyway it's a race condition.</span></p> 

<img src="https://pub-d6c34ccb68414a5bbfe746e44b7811ff.r2.dev/1-tkom/image7-min.png" alt="asd">

Does a button click for each search tag element.

### In human language:

Whenever you press the Delete Filters button, the jQuery function starts targeting each single filter element, removes it from the view, and asks the server for a response. And keeps doing this for each single filter tag you applied, sending a request for each. These single filter tag removals happen quite fast, so the requests sent by them happen almost simultaneously. Whichever of these filter requests wins the race, gets to be king of the screen.

<img src="https://pub-d6c34ccb68414a5bbfe746e44b7811ff.r2.dev/1-tkom/image8-min.png" alt="asd">

You can check it out <a href="https://www.deutschetelekomitsolutions.hu/en/open-positions/">here.</a>

### How to fix this?

Hire more junior frontenders with Kubernetes? Your devs probably know. Just cancel one of their daily standups and you're good to go.

### Credit where credit is due.

It's great to see jQuery from the 2010s, still in prod. Even if <a href="https://web.archive.org/web/20201124150805/https://www.deutschetelekomitsolutions.hu/karrier/nyitott-poziciok/">the site is from 2020.</a>, I'm sure it was just copied over from the previous. A good representation of not needing React and gigabundlers for everything to exist and be functional, even in 2024. Well, mostly functional. 


## Until next time, my sweet Magenta Princess.
