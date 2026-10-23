<?php
declare(strict_types=1);
namespace HaCrm\Domain;
use HaCrm\Core\Response;
final class BillingCalculator {
    public static function calculate(array $items,mixed $globalDiscount=0,string $discountType='amount'): array {
        if(!$items)Response::error('At least one line item is required.',422,['items'=>'Add at least one item.']);
        $rows=[];$subtotal=0.0;
        foreach($items as $i=>$item){if(!is_array($item)||trim((string)($item['item_name']??''))==='')Response::error('Each line needs a name.',422,["items.{$i}.item_name"=>'Required.']);$qty=(float)($item['quantity']??0);$price=(float)($item['unit_price']??-1);$rate=(float)($item['tax_rate']??0);$discountPct=(float)($item['discount_percent']??0);$discountAmt=(float)($item['discount_amount']??0);if($qty<=0||$price<0||$rate<0||$rate>100||$discountPct<0||$discountPct>100||$discountAmt<0)Response::error('Invalid line item quantity, price, tax, or discount.',422,["items.{$i}"=>'Check numeric values.']);$line=round($qty*$price,2);$lineDiscount=min($line,round($line*$discountPct/100+$discountAmt,2));$base=round($line-$lineDiscount,2);$subtotal=round($subtotal+$base,2);$rows[]=['item_name'=>trim($item['item_name']),'description'=>$item['description']??null,'quantity'=>number_format($qty,3,'.',''),'unit_price'=>number_format($price,2,'.',''),'discount_amount'=>number_format($discountAmt,2,'.',''),'discount_percent'=>number_format($discountPct,4,'.',''),'tax_rate'=>number_format($rate,4,'.',''),'line_subtotal'=>number_format($line,2,'.',''),'base'=>$base,'tax_rate_float'=>$rate];}
        $global=(float)$globalDiscount;if($global<0||$global>100000000000)Response::error('Invalid global discount.',422);if($discountType==='percent'){if($global>100)Response::error('Global discount percent cannot exceed 100.',422);$global=round($subtotal*$global/100,2);}else{$global=round($global,2);}if($global>$subtotal)Response::error('Discount cannot exceed subtotal.',422);$taxable=round($subtotal-$global,2);$taxTotal=0.0;
        foreach($rows as &$row){$share=$subtotal>0?round($global*($row['base']/$subtotal),2):0;$rowBase=max(0,round($row['base']-$share,2));$rowTax=round($rowBase*$row['tax_rate_float']/100,2);$row['taxable_amount']=number_format($rowBase,2,'.','');$row['tax_amount']=number_format($rowTax,2,'.','');$row['item_total']=number_format($rowBase+$rowTax,2,'.','');$taxTotal=round($taxTotal+$rowTax,2);unset($row['base'],$row['tax_rate_float']);}unset($row);
        return ['items'=>$rows,'subtotal'=>number_format($subtotal,2,'.',''),'global_discount'=>number_format($global,2,'.',''),'global_discount_type'=>$discountType,'taxable_amount'=>number_format($taxable,2,'.',''),'tax_total'=>number_format($taxTotal,2,'.',''),'grand_total'=>number_format($taxable+$taxTotal,2,'.','')];
    }
}
