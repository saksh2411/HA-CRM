<?php
declare(strict_types=1);
namespace HaCrm\Domain;
final class ResourceRegistry {
    public const MAP = [
      'leads'=>['table'=>'leads','fields'=>['salutation','first_name','last_name','job_title','company','email','secondary_email','phone','mobile','website','lead_status','lead_source','industry','lead_value','lead_score','priority','assigned_to','team_id','next_follow_up','internal_notes','source_cost'],'required'=>['first_name','last_name','email','phone'],'permission'=>'leads','owner'=>'assigned_to','team'=>'team_id'],
      'accounts'=>['table'=>'accounts','fields'=>['company_name','registration_number','industry','annual_revenue','employee_count','parent_account_id','phone','website','office_address','tax_id'],'required'=>['company_name'],'permission'=>'contacts','owner'=>null,'team'=>null],
      'contacts'=>['table'=>'contacts','fields'=>['account_id','first_name','last_name','email','phone','linkedin_url','billing_address','shipping_address','preferred_contact','assigned_to'],'required'=>['first_name','last_name','email'],'permission'=>'contacts','owner'=>'assigned_to','team'=>null],
      'deals'=>['table'=>'deals','fields'=>['deal_title','pipeline_id','stage_id','contact_id','account_id','source_lead_id','amount','discount_amount','tax_rate','currency','expected_close_date','loss_reason','assigned_to','team_id'],'required'=>['deal_title','pipeline_id','stage_id','amount','expected_close_date'],'permission'=>'deals','owner'=>'assigned_to','team'=>'team_id'],
      'quote-items'=>['table'=>'quote_items','fields'=>['quote_id','item_name','description','quantity','unit_price','discount_amount','discount_percent','tax_rate'],'required'=>['quote_id','item_name','quantity','unit_price'],'permission'=>'billing','owner'=>null,'team'=>null],
      'invoice-items'=>['table'=>'invoice_items','fields'=>['invoice_id','item_name','description','quantity','unit_price','discount_amount','discount_percent','tax_rate'],'required'=>['invoice_id','item_name','quantity','unit_price'],'permission'=>'billing','owner'=>null,'team'=>null],
      'pipelines'=>['table'=>'pipelines','fields'=>['name','is_default'],'required'=>['name'],'permission'=>'settings','owner'=>null,'team'=>null],
      'pipeline-stages'=>['table'=>'pipeline_stages','fields'=>['pipeline_id','name','position','probability','is_won','is_lost'],'required'=>['pipeline_id','name','position'],'permission'=>'settings','owner'=>null,'team'=>null],
      'activities'=>['table'=>'activities','fields'=>['activity_type','subject','related_type','related_id','due_at','duration_minutes','status','priority','description','assigned_to','team_id'],'required'=>['activity_type','subject','due_at'],'permission'=>'activities','owner'=>'assigned_to','team'=>'team_id'],
      'quotes'=>['table'=>'quotes','fields'=>['quote_number','deal_id','account_id','contact_id','status','issue_date','due_date','currency','terms','bank_details','customer_notes'],'required'=>['issue_date'],'permission'=>'billing','owner'=>null,'team'=>null],
      'invoices'=>['table'=>'invoices','fields'=>['quote_id','deal_id','account_id','contact_id','issue_date','due_date','currency','terms','bank_details','customer_notes'],'required'=>['issue_date','due_date'],'permission'=>'billing','owner'=>null,'team'=>null],
      'payments'=>['table'=>'payments','fields'=>['invoice_id','amount','currency','payment_date','method','reference','notes'],'required'=>['invoice_id','amount','payment_date'],'permission'=>'billing','owner'=>null,'team'=>null],
      'tickets'=>['table'=>'tickets','fields'=>['ticket_number','contact_id','account_id','subject','status','priority','assigned_to','sla_target_hours','sla_due_at'],'required'=>['subject'],'permission'=>'tickets','owner'=>'assigned_to','team'=>null],
      'ticket-messages'=>['table'=>'ticket_messages','fields'=>['ticket_id','author_type','author_id','message'],'required'=>['ticket_id','message'],'permission'=>'tickets','owner'=>null,'team'=>null],
      'ticket-notes'=>['table'=>'ticket_notes','fields'=>['ticket_id','author_id','note'],'required'=>['ticket_id','note'],'permission'=>'tickets','owner'=>null,'team'=>null],
      'users'=>['table'=>'users','fields'=>['full_name','email','role','status','eligible_for_leads'],'required'=>['full_name','email','role'],'permission'=>'users','owner'=>null,'team'=>null],
      'roles'=>['table'=>'roles','fields'=>['name'],'required'=>['name'],'permission'=>'users','owner'=>null,'team'=>null],
      'teams'=>['table'=>'teams','fields'=>['name'],'required'=>['name'],'permission'=>'users','owner'=>null,'team'=>null],
      'team-members'=>['table'=>'team_members','fields'=>['team_id','user_id'],'required'=>['team_id','user_id'],'permission'=>'users','owner'=>null,'team'=>null],
      'custom-fields'=>['table'=>'custom_field_definitions','fields'=>['entity_type','field_key','label','field_type','options_json','is_required','is_active','position'],'required'=>['entity_type','field_key','label','field_type'],'permission'=>'settings','owner'=>null,'team'=>null],
      'custom-field-values'=>['table'=>'custom_field_values','fields'=>['definition_id','entity_type','entity_id','value_text'],'required'=>['definition_id','entity_type','entity_id'],'permission'=>'settings','owner'=>null,'team'=>null],
      'quotas'=>['table'=>'user_monthly_quotas','fields'=>['user_id','month_start','target_amount'],'required'=>['user_id','month_start'],'permission'=>'reports','owner'=>null,'team'=>null]
    ];
}
