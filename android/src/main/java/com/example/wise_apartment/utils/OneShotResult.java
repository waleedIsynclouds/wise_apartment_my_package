package com.example.wise_apartment.utils;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.plugin.common.MethodChannel.Result;

/**
 * OneShotResult wraps a MethodChannel.Result and guarantees that only the
 * first call to success/error/notImplemented is forwarded to the delegate.
 * Subsequent calls are ignored and logged. All delegate invocations are
 * posted to the main (UI) thread.
 */
public final class OneShotResult implements Result {
  private final Result delegate;
  private final AtomicBoolean used = new AtomicBoolean(false);
  private final Handler mainHandler;
  private final String tag;

  public OneShotResult(Result delegate, String tag) {
    this.delegate = delegate;
    this.tag = tag == null ? "OneShotResult" : tag;
    this.mainHandler = new Handler(Looper.getMainLooper());
  }

  private void runOnMain(Runnable r) {
    if (Looper.myLooper() == Looper.getMainLooper()) {
      r.run();
    } else {
      mainHandler.post(r);
    }
  }

  @Override
  public void success(final Object result) {
    if (!used.compareAndSet(false, true)) {
      Log.w(tag, "Duplicate reply ignored: success");
      return;
    }
    runOnMain(() -> {
      try {
        delegate.success(result);
      } catch (Throwable t) {
        Log.w(tag, "Delegate success threw", t);
      }
    });
  }

  @Override
  public void error(final String errorCode, final String errorMessage, final Object errorDetails) {
    if (!used.compareAndSet(false, true)) {
      Log.w(tag, "Duplicate reply ignored: error -> " + errorCode);
      return;
    }
    runOnMain(() -> {
      try {
        delegate.error(errorCode, errorMessage, errorDetails);
      } catch (Throwable t) {
        Log.w(tag, "Delegate error threw", t);
      }
    });
  }

  @Override
  public void notImplemented() {
    if (!used.compareAndSet(false, true)) {
      Log.w(tag, "Duplicate reply ignored: notImplemented");
      return;
    }
    runOnMain(() -> {
      try {
        delegate.notImplemented();
      } catch (Throwable t) {
        Log.w(tag, "Delegate notImplemented threw", t);
      }
    });
  }
}
