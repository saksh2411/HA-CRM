<?php
declare(strict_types=1);
namespace HaCrm\Services;
use HaCrm\Core\{Config,Database};
use PHPMailer\PHPMailer\PHPMailer;
use HaCrm\Security\SmtpCipher;
final class Mailer {
    public static function send(int $tenant,string $to,string $subject,string $body): bool {
        $q=Database::connection()->prepare('SELECT * FROM smtp_settings WHERE tenant_id=? AND is_configured=1');$q->execute([$tenant]);$s=$q->fetch();if(!$s)return false;$key=(string)Config::get('APP_KEY','');$pass=$s['password_encrypted']?SmtpCipher::decrypt($s['password_encrypted'],$key):'';$mail=new PHPMailer(true);$mail->isSMTP();$mail->Host=$s['host'];$mail->Port=(int)$s['port'];$mail->SMTPAuth=(bool)$s['username'];$mail->Username=$s['username'];$mail->Password=$pass;$mail->SMTPSecure=$s['encryption']==='none'?'':($s['encryption']==='ssl'?PHPMailer::ENCRYPTION_SMTPS:PHPMailer::ENCRYPTION_STARTTLS);$mail->CharSet='UTF-8';$mail->setFrom($s['from_email'],$s['from_name']);$mail->addAddress($to);$mail->isHTML(false);$mail->Subject=$subject;$mail->Body=$body;return $mail->send();
    }
}
