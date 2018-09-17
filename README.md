# FlowState_HTN
FlowState App Developed For Hack The North

#Inspiration
We are living in the information age where we are constantly being overwhelmed.

Many of us are plagued by overconsumption because of endless distraction, whether it is social or technological. Distraction is the greatest threat to our productive future.

We are conditioned to do more and achieve more, so we resort to multitasking and busy-ness. These methods reward us with feelings of false significance.

Think of your daily 14-hour hustle:

how frequently are you experiencing interruptions during the day? --> how long does it take to get back on track?
are you prioritizing your tasks based on importance? --> are you overwhelmed?
James Johnston, a research psychologist at NASA declared that "When you multitask, it's inevitable each task will be slower and of lower quality."

In addition, a separate study conducted by the University of California Irvine concluded that when a person is distracted from their work, on average, they lose the Time Distracted + 23 mins 15 secs before getting back on track.

Jonathan Spira who authored Overload! How Too Much Information Is Hazardous To Your Organization estimates that these distractions cause the workforce to waste 28 billion hours a year, costing the US economy almost $1 trillion.

This means that we are constantly waging a losing battle with productivity. To solve that problem with FlowState, we want to empower people to get more done by doing less.

This will reduce stress, enhance equanimity, and boost creativity.

Boosting creativity is critical because according to the World Economic Forum, creativity will be one of the top 3 skills for career success in 2020.

We want to provide people with a tool to succeed.

#What it does
Our solution works for you by going to war against distractions.

We have built an active prioritization filter that blocks distractions and brings the user into a state that psychologists have termed flow.

A psychologist named Mihaly Csikszentmihalyi wrote in his book titled Flow, The Psychology of Optimal Experience that "flow is the state in which people are so involved in an activity that nothing else seems to matter; the experience itself is so enjoyable that people will do it even at great cost, for the sheer sake of doing it.”

Flow is the state that artists are in when creating timeless works of art. Flow is the state that athletes are in when it's extra time, they've got take the final shot, and they succeed. Flow can change how we do tasks - from maximizing our workflow to revolutionizing those which require intense concentration. In this regard, we could improve the concentration of surgeons such that the risk of mistakes is reduced (i.e. leaving an instrument in a patient).

#How we built it
We went through a rigorous cycle of trying to find the right framework that would allow us to access the data we were looking for in the Muse Headset, and one that would be easily manipulated to get the logic and functions complete before the end of the weekend.

We initially built out a boiler plate app in native iOS (Objective C), but were caught up a bit along this process. We then pivoted to the Cordova Hybrid app framework only to find that there was even less support there. All in all, on the last day we decided to re-visit our Objective C boiler plate where we knew we could get some raw EEG results, and braved it through the Objective C user interface design process.

#Challenges we ran into
There were many challenges in the Muse SDK that we were trying to utilize in our apps, and we often came up to compatibility issues, or functions that that the SDK docs didn't properly outline, or disclose their deprecation.

Another challenge we embraced, was determining the correct algorithm for calculating someones concentration level/percentage from raw EEG measurements. This was a fun, experimental process, that also proved to be quite challenging.

#Accomplishments that we're proud of
We are proud of the fact that we were able to get both the Muse SDK working to the degree that we initially hoped, and a decent UI combined into the same App, as we initially worried that we would have to set up a couple devices, one for reading EEG and the other for being the user facing app, but we ended up getting a bit crafty with our frameworks and managed to squeeze it in.

#What we learned
Documentation isn't ALWAYS right! They are prone to the same human errors that anything else would, and should be taken sometimes with a grain of salt. Also, planning is the key to success, as we managed to prove throughout Hack the North.

#What's next for Flow State
We hope to further develop out the application, add more features in like Slack message filtering to allow some VIP users to still be able to contact you regardless of your current FlowState. We would also like to open the floor to designing a system that could utilize the software we built this weekend, to create desks for some offices in the city, so that employees can book them off, and really get into their FlowState! We feel that there would be a decent market for an idea like this.


