package com.jakduk.core.notification;

import com.jakduk.core.CoreApplicationTests;
import com.jakduk.core.common.util.SlackUtils;
import com.jakduk.core.service.EmailService;
import org.junit.Ignore;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

import javax.mail.MessagingException;
import java.util.Locale;

/**
 * Created by pyohwan on 16. 9. 11.
 */
public class NotificationTest extends CoreApplicationTests {

    @Autowired
    private SlackUtils slackUtils;

    @Autowired
    private EmailService emailService;

    @Ignore
    @Test
    public void 슬랙알림() {
        slackUtils.send("test01", "hello");
    }

    @Ignore
    @Test
    public void 메일발송() throws MessagingException {

        Locale locale = Locale.KOREAN;

        emailService.sendMailWithInline("Pyohwan", "phjang1983@daum.net", locale);
    }

    @Ignore
    @Test
    public void 가입메일() throws MessagingException {

        Locale locale = Locale.KOREAN;

        emailService.sendWelcome(locale, "이은상", "phjang1983@daum.net");

    }

    @Ignore
    @Test
    public void 비밀번호_갱신() throws MessagingException {

        Locale locale = Locale.KOREAN;

        emailService.sendResetPassword(locale, "http://localhost:8080", "phjang1983@daum.net");

    }
}