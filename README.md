# Godot PostHog Analytics

A [Godot](https://godotengine.org/) addon to quickly add
[PostHog](https://posthog.com/) analytics to any project.

This addon has no official affiliation with Godot or PostHog.

## Why have analytics?

Analytics allow you to capture insightful metrics about how users interact with
your application or game. For example, you could measure:

- How many times your application is opened
- How many times a game is started
- What OS/Platform are users playing your game on
- How many levels players are completing in your game
- How many times players fail a certain level
- Etc.

PostHog provides a generous **free tier** that most small applications and games
can utilize. See [PostHog Pricing](https://posthog.com/pricing).

## Disclaimer

Please be aware that the implementation and use of analytics within your game
are your sole responsibility. This library provides tools to collect and
potentially transmit data, but it does not ensure compliance with any specific
privacy laws or regulations (such as GDPR, CCPA, etc.).

**It is your responsibility to:**

- Understand and comply with all applicable laws and regulations regarding data
  collection, storage, and usage in your target markets.
- Obtain any necessary user consent for data collection.
- Provide clear and transparent information to your users about the data you are
  collecting and how it will be used.
- Ensure the security and privacy of any collected data.

The developers of this library assume no liability for your implementation or
any failure to comply with relevant legal and ethical standards. Use this
library responsibly and with due diligence.

As a starting point, consider reading
[PostHog's Privacy Compliance documentation](https://posthog.com/docs/privacy).

## Setup

### PostHog Project

If you don't already have one, create a [PostHog](https://posthog.com/) account
an organization. You can create one organization for each Godot project.

### Download the addon

- Download the repository
  - See
    [Downloading a repository's files](https://docs.github.com/en/get-started/start-your-journey/downloading-files-from-github#downloading-a-repositorys-files)

### Godot Project

- Place the `PostHog` directory in your project's `addons` directory
- Add `res://addons/Posthog/post_hog.gd` as an
  [Autoload](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)
  with the name `PostHog`

### posthog.json

In your root project directory (`res://`), create a new file: `posthog.json`.
There should be two keys in this file, `api_key` and `base_url`:

```json
{
  "api_key": "<POSTHOG_PROJECT_API_KEY>",
  "base_url": "https://us.i.posthog.com"
}
```

You can find your project API key under the PostHog organization's default
project settings. Or try this url with your project ID:

```
https://us.posthog.com/project/<PROJECT_ID>/settings/project#variables
```

> [!IMPORTANT]
> If you plan on sharing your project code, it is recommended that you don't
> share your PostHog project API key. Add `posthog.json` to your `.gitignore`
> for public repositories.

As of April 2025, your `base_url` should be either `https://us.i.posthog.com`
for US Cloud or `https://eu.i.posthog.com` for EU Cloud. From your project
dashboard, the url should signal which Cloud you are using. See the
[PostHog API endpoint documentation](https://posthog.com/docs/api/capture) to
verify what `base_url` should be used. **Don't include the path** (`/i/v0/e` or
`/batch`).

## Usage

### Capture

In any script, you can start capturing events:

```gdscript
# Any event (String)
PostHog.capture("event_name")

# With extra properties (Dictionary)
PostHog.capture("event_name", {
  "level_name": level_name,
})
```

### Auto include properties

If you have something you want recorded with every event, add it to the
`PostHog.auto_include_properties` Dictionary. **Reminder:** consider any
compliance requirements before you included identifiable data.

```gdscript
PostHog.auto_include_properties["distribution_platform"] = "itchio"
```

Every event captured after this will contain properties from this Dictionary.
They can be erased.

```gdscript
PostHog.auto_include_properties.erase("distribution_platform")
```

### Anonymous events

[Anonymous events](https://posthog.com/docs/data/anonymous-vs-identified-events)
are enabled by default. Change the `anonymous_events` member variable to change
this behavior. **Reminder:** consider any compliance requirements when switching
to
[identified events](https://posthog.com/docs/data/anonymous-vs-identified-events).

```gdscript
# Use identified events.
PostHog.anonymous_events = false
```

## PostHog dashboards

To see your metrics in PostHog, create a new
[insight](https://posthog.com/docs/product-analytics/insights) with your event
name. Add the insight to your
[dashboard](https://posthog.com/docs/product-analytics/dashboards).

Creating an insight:

![PostHog Insight Example](.gdignore\assets\godot_posthog_insight_example.png)

Dashboard example:

![PostHog Dashboard Example](.gdignore\assets\godot_posthog_dashboard_example.png)

## License

MIT License. See [LICENSE.txt](addons\PostHog\LICENSE.txt)
