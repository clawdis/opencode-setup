# Event-Driven Dialog Auto-Close

## Overview

Pattern for WPF dialogs that block UI but need to auto-close when asynchronous data arrives from background operations. Enables seamless user experience where dialogs automatically dismiss themselves when their purpose is fulfilled.

## Problem Statement

Traditional dialog flow:
1. User action triggers dialog (ShowDialog blocks UI)
2. User manually interacts with dialog
3. User clicks OK/Cancel to close

Event-driven flow:
1. User action triggers dialog (ShowDialog blocks UI)
2. Background operation completes asynchronously
3. Dialog auto-closes with new data
4. User never needs to manually dismiss

## Architecture

```
Background Thread (HTTP Server, Timer, File Watcher)
    ↓ data arrives
Static Event in Data Layer (CookieManager.cs)
    ↓ raises event
Dialog (CloudflareCookieDialog.cs)
    ↓ subscribes on construction
    ↓ receives event on background thread
Dispatcher.Invoke
    ↓ marshals to UI thread
DialogResult = true
    ↓ closes dialog
Calling Code
    ↓ receives DialogResult
    ↓ proceeds with new data
```

## Implementation Pattern

### 1. Data Layer with Static Event

**CookieManager.cs**:
```csharp
public static class CookieManager
{
    private static readonly object s_lock = new object();
    
    // Static event for dialog subscription
    public static event EventHandler CookiesUpdated;
    
    public static void Initialize()
    {
        // Subscribe to HTTP server events
        CookieSyncServer.CookiesReceived += OnCookiesReceived;
    }
    
    private static void OnCookiesReceived(object sender, CookieSyncEventArgs e)
    {
        lock (s_lock)
        {
            var cookies = ConvertChromeCookies(e.Data.Cookies);
            SaveCookies(cookies);
        }
        
        // Raise event for UI subscribers
        CookiesUpdated?.Invoke(null, EventArgs.Empty);
    }
}
```

### 2. Dialog with Event Subscription

**CloudflareCookieDialog.xaml.cs**:
```csharp
public partial class CloudflareCookieDialog : Window
{
    public CloudflareCookieDialog()
    {
        InitializeComponent();
        
        // Subscribe to cookie updates
        CookieManager.CookiesUpdated += OnCookiesUpdated;
        
        // Unsubscribe when dialog closes to prevent memory leaks
        Closed += (s, e) => CookieManager.CookiesUpdated -= OnCookiesUpdated;
    }
    
    private void OnCookiesUpdated(object sender, EventArgs e)
    {
        // Event arrives on background thread, marshal to UI thread
        Dispatcher.Invoke(() =>
        {
            // Auto-close dialog with success result
            DialogResult = true;
        });
    }
    
    private void CancelButton_Click(object sender, RoutedEventArgs e)
    {
        DialogResult = false;
    }
}
```

### 3. Calling Code

**ScraperViewModel.cs**:
```csharp
private async Task HandleCloudflareChallenge()
{
    var dialog = new CloudflareCookieDialog();
    var result = dialog.ShowDialog();
    
    if (result == true)
    {
        // Cookies were updated, retry scraping
        await RetryScraping();
    }
    else
    {
        // User cancelled
        ShowError("Scraping cancelled by user");
    }
}
```

## Key Technical Insights

### Thread Safety with Dispatcher.Invoke

Events from background threads cannot directly modify UI:

```csharp
// ❌ Crashes - cross-thread operation
private void OnCookiesUpdated(object sender, EventArgs e)
{
    DialogResult = true;  // InvalidOperationException
}

// ✅ Safe - marshals to UI thread
private void OnCookiesUpdated(object sender, EventArgs e)
{
    Dispatcher.Invoke(() =>
    {
        DialogResult = true;
    });
}
```

### Memory Leak Prevention

Always unsubscribe from static events:

```csharp
// ❌ Memory leak - dialog never garbage collected
public CloudflareCookieDialog()
{
    CookieManager.CookiesUpdated += OnCookiesUpdated;
}

// ✅ Proper cleanup
public CloudflareCookieDialog()
{
    CookieManager.CookiesUpdated += OnCookiesUpdated;
    Closed += (s, e) => CookieManager.CookiesUpdated -= OnCookiesUpdated;
}
```

### DialogResult Behavior

Setting `DialogResult` automatically closes the dialog:

```csharp
// These are equivalent:
DialogResult = true;
// vs
DialogResult = true;
Close();  // Redundant, already closed
```

## Advanced Patterns

### Timeout with Auto-Close

```csharp
public partial class CloudflareCookieDialog : Window
{
    private DispatcherTimer _timeoutTimer;
    
    public CloudflareCookieDialog(TimeSpan timeout)
    {
        InitializeComponent();
        
        CookieManager.CookiesUpdated += OnCookiesUpdated;
        Closed += OnClosed;
        
        // Auto-close after timeout
        _timeoutTimer = new DispatcherTimer { Interval = timeout };
        _timeoutTimer.Tick += (s, e) =>
        {
            _timeoutTimer.Stop();
            DialogResult = false;  // Timeout = cancel
        };
        _timeoutTimer.Start();
    }
    
    private void OnCookiesUpdated(object sender, EventArgs e)
    {
        Dispatcher.Invoke(() =>
        {
            _timeoutTimer.Stop();
            DialogResult = true;
        });
    }
    
    private void OnClosed(object sender, EventArgs e)
    {
        _timeoutTimer?.Stop();
        CookieManager.CookiesUpdated -= OnCookiesUpdated;
    }
}
```

### Data Passing with EventArgs

```csharp
public class CookieUpdateEventArgs : EventArgs
{
    public List<Cookie> NewCookies { get; set; }
    public string SourceUrl { get; set; }
}

// In CookieManager
public static event EventHandler<CookieUpdateEventArgs> CookiesUpdated;

// In Dialog
private void OnCookiesUpdated(object sender, CookieUpdateEventArgs e)
{
    Dispatcher.Invoke(() =>
    {
        StatusText.Text = $"Received {e.NewCookies.Count} cookies from {e.SourceUrl}";
        DialogResult = true;
    });
}
```

### Conditional Auto-Close

```csharp
private void OnCookiesUpdated(object sender, CookieUpdateEventArgs e)
{
    Dispatcher.Invoke(() =>
    {
        // Only auto-close if required cookies are present
        var hasRequiredCookies = e.NewCookies.Any(c => c.Name == "cf_clearance");
        
        if (hasRequiredCookies)
        {
            StatusText.Text = "✓ Required cookies received";
            DialogResult = true;
        }
        else
        {
            StatusText.Text = "⚠ Cookies received but cf_clearance missing";
            // Keep dialog open for user to retry
        }
    });
}
```

## Common Use Cases

### 1. Cookie Sync Dialog
User solves Cloudflare → Extension sends cookies → Dialog auto-closes

### 2. File Upload Progress
User selects file → Upload completes → Dialog auto-closes

### 3. Background Processing
User starts operation → Processing completes → Dialog auto-closes

### 4. Network Request Wait
User triggers request → Response arrives → Dialog auto-closes

### 5. Timer-Based Operations
User starts timer → Timer expires → Dialog auto-closes

## Testing Considerations

### Manual Testing

```csharp
// Test button to simulate event
private void TestAutoClose_Click(object sender, RoutedEventArgs e)
{
    Task.Run(async () =>
    {
        await Task.Delay(2000);
        CookieManager.CookiesUpdated?.Invoke(null, EventArgs.Empty);
    });
}
```

### Unit Testing

```csharp
[Test]
public void Dialog_AutoCloses_WhenCookiesUpdated()
{
    var dialog = new CloudflareCookieDialog();
    
    Task.Run(() =>
    {
        Thread.Sleep(100);
        CookieManager.CookiesUpdated?.Invoke(null, EventArgs.Empty);
    });
    
    var result = dialog.ShowDialog();
    Assert.IsTrue(result);
}
```

## Error Handling

```csharp
private void OnCookiesUpdated(object sender, EventArgs e)
{
    try
    {
        Dispatcher.Invoke(() =>
        {
            try
            {
                // Validate state before closing
                if (!IsLoaded)
                    return;
                
                DialogResult = true;
            }
            catch (InvalidOperationException)
            {
                // Dialog already closed, ignore
            }
        });
    }
    catch (TaskCanceledException)
    {
        // Dispatcher shutdown, ignore
    }
}
```

## Related Patterns

- Chrome Extension Desktop Integration (see `chrome-extension-desktop-integration` skill)
- Static manager thread safety (see `javluv-patterns` skill)
- WPF MVVM patterns (see `javluv-wpf-mvvm` skill)

## Anti-Patterns to Avoid

### ❌ Blocking Wait in Dialog Constructor

```csharp
// Never block the UI thread waiting for events
public CloudflareCookieDialog()
{
    InitializeComponent();
    
    // ❌ Deadlock risk
    var task = Task.Run(() => WaitForCookies());
    task.Wait();
}
```

### ❌ Polling Instead of Events

```csharp
// ❌ Wasteful CPU usage
private void StartPolling()
{
    var timer = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(100) };
    timer.Tick += (s, e) =>
    {
        if (CookieManager.HasNewCookies())
            DialogResult = true;
    };
    timer.Start();
}
```

### ❌ Forgetting to Unsubscribe

```csharp
// ❌ Memory leak
public CloudflareCookieDialog()
{
    CookieManager.CookiesUpdated += OnCookiesUpdated;
    // Missing: Closed += (s, e) => CookieManager.CookiesUpdated -= OnCookiesUpdated;
}
```
