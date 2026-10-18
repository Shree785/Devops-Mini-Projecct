package com.securitylog.e2e;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.TestInfo;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public abstract class BaseSeleniumTest {

    @LocalServerPort
    protected int port;

    protected WebDriver driver;
    protected WebDriverWait wait;

    protected static final String SCREENSHOT_DIR = "target/screenshots";
    protected static final String DELIVERABLES_SCREENSHOT_DIR = "deliverables/task-09/screenshots";

    @BeforeEach
    void setupDriver() {
        ChromeOptions options = new ChromeOptions();
        options.addArguments("--headless=new");
        options.addArguments("--disable-gpu");
        options.addArguments("--no-sandbox");
        options.addArguments("--disable-dev-shm-usage");
        options.addArguments("--window-size=1920,1080");

        driver = new ChromeDriver(options);
        wait = new WebDriverWait(driver, Duration.ofSeconds(10));
    }

    @AfterEach
    void tearDown(TestInfo testInfo) {
        if (driver != null) {
            try {
                driver.quit();
            } catch (Exception ignored) {
            }
        }
    }

    protected String getBaseUrl() {
        return "http://localhost:" + port;
    }

    protected WebElement waitForVisible(By locator) {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(locator));
    }

    protected WebElement waitForClickable(By locator) {
        return wait.until(ExpectedConditions.elementToBeClickable(locator));
    }

    protected void clickWithJs(WebElement element) {
        ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView(true); arguments[0].click();", element);
    }

    public File captureScreenshot(String testName) {
        if (driver instanceof TakesScreenshot) {
            File srcFile = ((TakesScreenshot) driver).getScreenshotAs(OutputType.FILE);
            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
            String fileName = testName + "_" + timestamp + ".png";

            try {
                Path targetPath = Paths.get(SCREENSHOT_DIR, fileName);
                Files.createDirectories(targetPath.getParent());
                Files.copy(srcFile.toPath(), targetPath, StandardCopyOption.REPLACE_EXISTING);

                Path deliverablePath = Paths.get(DELIVERABLES_SCREENSHOT_DIR, fileName);
                Files.createDirectories(deliverablePath.getParent());
                Files.copy(srcFile.toPath(), deliverablePath, StandardCopyOption.REPLACE_EXISTING);

                return targetPath.toFile();
            } catch (IOException e) {
                System.err.println("Failed to save screenshot: " + e.getMessage());
            }
        }
        return null;
    }
}
