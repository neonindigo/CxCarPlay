# CxCarPlay binds per-item handlers rather than installing a template delegate

CxCarPlay injects selection handlers directly into `CPListItem` objects when sections are bound via `cx.bind(sections:)`. It does not install itself as `CPListTemplateDelegate`.

The alternative — installing a `CPListTemplateDelegate` — would intercept selection for any sections, including those set manually via `template.updateSections`. This was rejected because it would make `cx.itemSelected` emit events for items that were never bound through CxCarPlay, creating a confusing split between reactive and imperative usage in the same template. Per-item handler injection makes the coupling explicit and visible: selections only arrive when a binding is active.

This approach requires iOS 14+ (`CPListItem.handler` was introduced in iOS 14). CxCarPlay targets iOS 15+, so the requirement is satisfied without availability guards.
