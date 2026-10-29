# Agent Contract
Governance subsystem that enforces exclusive file ownership and detects unauthorized changes.

Claims do not expire into permission to write. TTL expiry is diagnostic only:
reconcile the prior owner and use the existing explicit cancellation/completion
transition before reassigning overlapping paths. Disjoint claims remain available.
The stable sibling-file flock serializes cooperating CLI calls sharing one ledger;
it does not establish a distributed lock across independent runner filesystems or
prevent arbitrary filesystem writes that bypass this CLI.
