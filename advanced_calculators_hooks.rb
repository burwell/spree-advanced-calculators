class AdvancedCalculatorsHooks < Spree::ThemeSupport::HookListener
  insert_after :admin_configurations_menu do
    %Q{
      <tr>
        <td><%= link_to t("bucket_rates"), admin_bucket_rates_path %></td>
        <td><%= t("bucket_rates_setting_description") %></td>
      </tr>
    }
  end
end
