Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public static class LogoBg
{
    public static void Remove(string src, string dst, double tol, double edgeTol)
    {
        using (var bmp = new Bitmap(src))
        {
            int w = bmp.Width, h = bmp.Height;

            Color tl = bmp.GetPixel(0, 0);
            Color tr = bmp.GetPixel(w - 1, 0);
            Color bl = bmp.GetPixel(0, h - 1);
            Color br = bmp.GetPixel(w - 1, h - 1);

            double rB = (tl.R + tr.R + bl.R + br.R) / 4.0;
            double gB = (tl.G + tr.G + bl.G + br.G) / 4.0;
            double bB = (tl.B + tr.B + bl.B + br.B) / 4.0;

            int n = w * h;
            byte[] R = new byte[n], G = new byte[n], B = new byte[n];
            bool[] rem = new bool[n];

            // Read pixels via LockBits.
            BitmapData bd = bmp.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            byte[] px = new byte[bd.Stride * h];
            Marshal.Copy(bd.Scan0, px, 0, px.Length);
            bmp.UnlockBits(bd);

            for (int y = 0; y < h; y++)
            {
                int row = y * bd.Stride;
                for (int x = 0; x < w; x++)
                {
                    int off = row + x * 4;
                    int i = y * w + x;
                    B[i] = px[off];
                    G[i] = px[off + 1];
                    R[i] = px[off + 2];
                }
            }

            // Distance for pixel i to background color.
            Func<int, double> dist = i =>
            {
                double dr = R[i] - rB, dg = G[i] - gB, db = B[i] - bB;
                return Math.Sqrt(dr * dr + dg * dg + db * db);
            };

            int[] dx = { 1, -1, 0, 0 };
            int[] dy = { 0, 0, 1, -1 };

            // Seed flood fill from borders.
            var stack = new Stack<int>();
            bool push(int x, int y)
            {
                int i = y * w + x;
                if (!rem[i] && dist(i) <= tol) { rem[i] = true; stack.Push(i); return true; }
                return false;
            }
            for (int y = 0; y < h; y++) { push(0, y); push(w - 1, y); }
            for (int x = 0; x < w; x++) { push(x, 0); push(x, h - 1); }

            while (stack.Count > 0)
            {
                int i = stack.Pop();
                int x = i % w, y = i / w;
                for (int k = 0; k < 4; k++)
                {
                    int nx = x + dx[k], ny = y + dy[k];
                    if (nx < 0 || nx >= w || ny < 0 || ny >= h) continue;
                    push(nx, ny);
                }
            }

            Func<int, bool> adjRem = i =>
            {
                int x = i % w, y = i / w;
                for (int k = 0; k < 4; k++)
                {
                    int nx = x + dx[k], ny = y + dy[k];
                    if (nx < 0 || nx >= w || ny < 0 || ny >= h) continue;
                    if (rem[ny * w + nx]) return true;
                }
                return false;
            };

            // Write output.
            using (var outBmp = new Bitmap(w, h, PixelFormat.Format32bppArgb))
            {
                BitmapData obd = outBmp.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
                byte[] opx = new byte[obd.Stride * h];
                for (int y = 0; y < h; y++)
                {
                    int row = y * obd.Stride;
                    for (int x = 0; x < w; x++)
                    {
                        int i = y * w + x;
                        int off = row + x * 4;
                        int a = 255;
                        if (rem[i])
                        {
                            a = 0;
                        }
                        else
                        {
                            double d = dist(i);
                            if (d <= edgeTol && adjRem(i))
                            {
                                double t = (d - tol) / (edgeTol - tol);
                                if (t < 0) t = 0; else if (t > 1) t = 1;
                                a = (int)Math.Round(t * 255);
                            }
                        }
                        opx[off] = B[i];
                        opx[off + 1] = G[i];
                        opx[off + 2] = R[i];
                        opx[off + 3] = (byte)a;
                    }
                }
                Marshal.Copy(opx, 0, obd.Scan0, opx.Length);
                outBmp.UnlockBits(obd);
                outBmp.Save(dst, ImageFormat.Png);
            }

            int removed = 0;
            for (int i = 0; i < n; i++) if (rem[i]) removed++;
            System.Console.WriteLine("Size: {0} x {1}", w, h);
            System.Console.WriteLine("Transparent px: {0} / {1} ({2}%)", removed, n, Math.Round(removed * 100.0 / n, 1));
        }
    }
}
'@

[LogoBg]::Remove("C:\Users\ReyesArold\Desktop\myapp\assets\icon\logo.jpg", "C:\Users\ReyesArold\Desktop\myapp\assets\icon\app_logo.png", 55.0, 95.0)
"Done"