defmodule Mix.Tasks.Nostrum.UpdateApiFunctions do
  @moduledoc """
  Update all calls to deprecated `Nostrum.Api` functions.

  **Please either use source control or have some other backup of your data
  before running this task.**

  Please note that this task does not currently update the module aliases as
  required to have the new calls work.

  This may eat your data and cause irrecovable data loss. Please see nostrum's
  user manual, p. 512, "Musings on data safety outside of distributed mnesia
  databases" for more details.
  """
  @moduledoc since: "0.11.0"

  use Mix.Task

  @shortdoc "Update deprecated calls to `Nostrum.Api`."
  def run(_) do
    Path.wildcard("lib/**/*.ex")
    |> update_modules()
  end

  defp update_modules([]) do
    :ok
  end

  defp update_modules([module | modules]) do
    update_module(module)
    update_modules(modules)
  end

  defp update_module(module) do
    IO.write("#{module} ")
    source = File.read!(module)

    {_quoted, patches} =
      source
      |> Sourceror.parse_string!()
      |> Macro.postwalk([], &patch_calls/2)

    patched = Sourceror.patch_string(source, patches)
    File.write!(module, patched)
    IO.write("\n")
  end

  @replacements %{
    create_message: {:Message, :create},
    update_shard_status: {:Self, :update_shard_status},
    update_status: {:Self, :update_status},
    update_voice_state: {:Self, :update_voice_state},
    edit_message: {:Message, :edit},
    delete_message: {:Message, :delete},
    create_reaction: {:Message, :react},
    delete_own_reaction: {:Message, :unreact},
    delete_user_reaction: {:Message, :delete_user_reaction},
    delete_reaction: {:Message, :delete_emoji_reactions},
    get_reactions: {:Message, :reactions},
    delete_all_reactions: {:Message, :clear_reactions},
    get_poll_answer_voters: {:Poll, :answer_voters},
    expire_poll: {:Poll, :expire},
    get_channel: {:Channel, :get},
    modify_channel: {:Channel, :modify},
    delete_channel: {:Channel, :delete},
    get_channel_messages: {:Channel, :messages},
    get_channel_message: {:Message, :get},
    bulk_delete_messages: {:Channel, :bulk_delete_messages},
    edit_channel_permissions: {:Channel, :edit_permissions},
    delete_channel_permissions: {:Channel, :delete_permissions},
    get_channel_invites: {:Invite, :channel_invites},
    create_channel_invite: {:Invite, :create},
    start_typing: {:Channel, :start_typing},
    get_pinned_messages: {:Channel, :get_pinned_messages},
    add_pinned_channel_message: {:Channel, :pin_message},
    delete_pinned_channel_message: {:Channel, :unpin_message},
    list_guild_emojis: {:Guild, :emojis},
    get_guild_emoji: {:Guild, :emoji},
    create_guild_emoji: {:Guild, :create_emoji},
    modify_guild_emoji: {:Guild, :modify_emoji},
    delete_guild_emoji: {:Guild, :delete_emoji},
    get_sticker: {:Sticker, :get},
    list_guild_stickers: {:Sticker, :list},
    get_guild_sticker: {:Sticker, :get},
    modify_guild_sticker: {:Sticker, :modify},
    delete_guild_sticker: {:Sticker, :delete},
    get_sticker_packs: {:Sticker, :packs},
    get_guild_audit_log: {:Guild, :audit_log},
    get_guild: {:Guild, :get},
    modify_guild: {:Guild, :modify},
    delete_guild: {:Guild, :delete},
    get_guild_channels: {:Guild, :channels},
    create_guild_channel: {:Channel, :create},
    modify_guild_channel_positions: {:Guild, :modify_channel_positions},
    get_guild_member: {:Guild, :member},
    list_guild_members: {:Guild, :members},
    add_guild_member: {:Guild, :add_member},
    modify_guild_member: {:Guild, :modify_member},
    modify_current_user_nick: {:Guild, :modify_self_nick},
    add_guild_member_role: {:Guild, :add_member_role},
    remove_guild_member_role: {:Guild, :remove_member_role},
    remove_guild_member: {:Guild, :kick_member},
    get_guild_ban: {:Guild, :ban},
    get_guild_bans: {:Guild, :bans},
    create_guild_ban: {:Guild, :ban_member},
    remove_guild_ban: {:Guild, :unban_member},
    get_guild_roles: {:Guild, :roles},
    create_guild_role: {:Guild, :create_role},
    modify_guild_role_positions: {:Guild, :modify_role_positions},
    modify_guild_role: {:Guild, :modify_role},
    delete_guild_role: {:Guild, :delete_guild_role},
    get_guild_prune_count: {:Guild, :estimate_prune_count},
    begin_guild_prune: {:Guild, :begin_prune},
    get_voice_region: {:Guild, :voice_region},
    get_guild_invites: {:Invite, :guild_invites},
    get_guild_integrations: {:Guild, :integrations},
    create_guild_integrations: {:Guild, :create_integration},
    modify_guild_integrations: {:Guild, :modify_integration},
    delete_guild_integrations: {:Guild, :delete_integration},
    sync_guild_integrations: {:Guild, :sync_integration},
    get_guild_widget: {:Guild, :widget},
    modify_guild_widget: {:Guild, :modify_widget},
    create_guild_scheduled_event: {:ScheduledEvent, :create},
    get_guild_scheduled_events: {:Guild, :scheduled_events},
    get_guild_scheduled_event: {:ScheduledEvent, :get},
    delete_guild_scheduled_event: {:ScheduledEvent, :delete},
    modify_guild_scheduled_event: {:ScheduledEvent, :modify},
    get_guild_scheduled_event_users: {:ScheduledEvent, :users},
    get_invite: {:Invite, :get},
    delete_invite: {:Invite, :delete},
    get_user: {:User, :get},
    get_current_user: {:Self, :get},
    modify_current_user: {:Self, :modify},
    get_current_user_guilds: {:Self, :guilds},
    leave_guild: {:Guild, :leave},
    get_user_dms: {:Self, :dms},
    create_dm: {:User, :create_dm},
    create_group_dm: {:User, :create_group_dm},
    get_user_connections: {:Self, :connections},
    list_voice_regions: {:Guild, :voice_regions},
    create_webhook: {:Webhook, :create},
    get_webhook_message: {:Webhook, :get_message},
    get_channel_webhooks: {:Channel, :webhooks},
    get_guild_webhooks: {:Guild, :webhooks},
    get_webhook: {:Webhook, :get},
    get_webhook_with_token: {:Webhook, :get_with_token},
    modify_webhook: {:Webhook, :modify},
    modify_webhook_with_token: {:Webhook, :modify_with_token},
    delete_webhook: {:Webhook, :delete},
    execute_webhook: {:Webhook, :execute},
    edit_webhook_message: {:Webhook, :edit_message},
    execute_slack_webhook: {:Webhook, :execute_slack},
    execute_git_webhook: {:Webhook, :execute_git},
    get_application_information: {:Self, :application_information},
    get_global_application_commands: {:ApplicationCommand, :global_commands},
    create_global_application_command: {:ApplicationCommand, :create_global_command},
    edit_global_application_command: {:ApplicationCommand, :edit_global_command},
    delete_global_application_command: {:ApplicationCommand, :delete_global_command},
    bulk_overwrite_global_application_commands:
      {:ApplicationCommand, :bulk_overwrite_global_commands},
    get_guild_application_commands: {:ApplicationCommand, :guild_commands},
    create_guild_application_command: {:ApplicationCommand, :create_guild_command},
    edit_guild_application_command: {:ApplicationCommand, :edit_guild_command},
    delete_guild_application_command: {:ApplicationCommand, :delete_guild_command},
    bulk_overwrite_guild_application_commands:
      {:ApplicationCommand, :bulk_overwrite_guild_commands},
    # XXX: there are two separate functions here for some reason
    create_interaction_response: {:Interaction, :create_response},
    get_original_interaction_response: {:Interaction, :original_response},
    edit_interaction_response: {:Interaction, :edit_response},
    delete_interaction_response: {:Interaction, :delete_response},
    create_followup_message: {:Interaction, :create_followup_message},
    delete_interaction_followup_message: {:Interaction, :delete_followup_message},
    get_guild_application_command_permissions: {:ApplicationCommand, :guild_permissions},
    get_application_command_permissions: {:ApplicationCommand, :permissions},
    edit_application_command_permissions: {:ApplicationCommand, :edit_command_permissions},
    batch_edit_application_command_permissions: {:ApplicationCommand, :batch_edit_permissions},
    start_thread_with_message: {:Thread, :create_with_message},
    start_thread_in_forum_channel: {:Thread, :create_in_forum},
    get_thread_member: {:Thread, :member},
    get_thread_members: {:Thread, :members},
    list_guild_threads: {:Thread, :list},
    list_public_archived_threads: {:Thread, :public_archived_threads},
    list_private_archived_threads: {:Thread, :private_archived_threads},
    list_joined_private_archived_threads: {:Thread, :joined_private_archived_threads},
    join_thread: {:Thread, :join},
    add_thread_member: {:Thread, :add_member},
    leave_thread: {:Thread, :leave},
    remove_thread_member: {:Thread, :remove_member},
    get_guild_auto_moderation_rules: {:AutoModeration, :rules},
    get_guild_auto_moderation_rule: {:AutoModeration, :rule},
    create_guild_auto_moderation_rule: {:AutoModeration, :create_rule},
    modify_guild_auto_moderation_rule: {:AutoModeration, :modify_rule},
    delete_guild_auto_moderation_rule: {:AutoModeration, :delete_rule}
  }

  defp patch_calls(quoted, patches) do
    case quoted do
      {:., dot_meta, [{:__aliases__, alias_meta, [:Api]}, function]} ->
        case Map.get(@replacements, function) do
          {module, function} ->
            range = Sourceror.get_range(quoted)

            replacement =
              {:., dot_meta, [{:__aliases__, alias_meta, [module]}, function]}
              |> Sourceror.to_string()
              |> String.replace(" . :", ".", global: false)

            patch = %{range: range, change: replacement}
            IO.write(".")
            {quoted, [patch | patches]}

          _ ->
            {quoted, patches}
        end

      _ ->
        {quoted, patches}
    end
  end
end
