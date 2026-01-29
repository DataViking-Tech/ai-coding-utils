from slack.notifier import SlackConfig, SlackNotifier

config = SlackConfig(webhook_url="https://hooks.slack.com/services/T000/B000/XXXX")
notifier = SlackNotifier(config)
notifier.send("Hello from ai-coding-utils")
